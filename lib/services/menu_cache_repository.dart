import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/service/menu_api.dart';
import 'package:restaurant/services/firestore_cache_metrics.dart';

/// Owner menu cache: Memory → Disk → CF getVendorOwnerMenu → Firestore.
class MenuCacheRepository {
  MenuCacheRepository._();

  static final MenuCacheRepository instance = MenuCacheRepository._();

  static const Duration cacheTtl = Duration(minutes: 20);

  final Map<String, _CachedMenu> _memoryCache = {};
  final Map<String, Future<List<ProductModel>>> _inFlight = {};

  Directory? _cacheDir;

  Future<Directory> _dir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${base.path}/owner_menu_cache');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    return _cacheDir!;
  }

  String _filePath(String vendorId) =>
      '${_cacheDir?.path ?? ''}/owner_menu_$vendorId.json';

  Future<List<ProductModel>> getMenu(
    String vendorId, {
    int? menuVersion,
    bool forceRefresh = false,
  }) {
    if (vendorId.isEmpty) {
      return Future.value(const <ProductModel>[]);
    }

    if (!forceRefresh) {
      final memory = _memoryCache[vendorId];
      if (memory != null && memory.isValid(menuVersion: menuVersion)) {
        FirestoreCacheMetrics.menuCacheHits++;
        FirestoreCacheMetrics.log('memory_hit', data: {
          'vendorId': vendorId,
          'items': memory.products.length,
          'menuVersion': memory.menuVersion,
        });
        return Future.value(List<ProductModel>.from(memory.products));
      }
    }

    final existing = _inFlight[vendorId];
    if (existing != null) {
      FirestoreCacheMetrics.menuDedupedRequests++;
      return existing;
    }

    final future = _loadMenu(
      vendorId,
      menuVersion: menuVersion,
      forceRefresh: forceRefresh,
    );
    _inFlight[vendorId] = future;
    return future.whenComplete(() => _inFlight.remove(vendorId));
  }

  Future<List<ProductModel>> _loadMenu(
    String vendorId, {
    int? menuVersion,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final disk = await _readPersistent(vendorId);
      if (disk != null && disk.isValid(menuVersion: menuVersion)) {
        _memoryCache[vendorId] = disk;
        FirestoreCacheMetrics.menuCacheHits++;
        return List<ProductModel>.from(disk.products);
      }
    }

    FirestoreCacheMetrics.menuCacheMisses++;
    FirestoreCacheMetrics.menuFetches++;

    final products = await MenuApi.getOwnerMenu(
      vendorId: vendorId,
      forceRefresh: forceRefresh,
    );

    List<ProductModel> list;
    int? version = menuVersion;
    if (products != null) {
      list = products;
    } else {
      list = await _fetchFromFirestore(vendorId);
    }

    final cached = _CachedMenu(
      vendorId: vendorId,
      products: list,
      cachedAt: DateTime.now(),
      menuVersion: version,
    );
    _memoryCache[vendorId] = cached;
    await _writePersistent(cached);
    return List<ProductModel>.from(list);
  }

  static Future<List<ProductModel>> _fetchFromFirestore(String vendorId) async {
    final list = <ProductModel>[];
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(CollectionName.vendorProducts)
          .where('vendorID', isEqualTo: vendorId)
          .orderBy('createdAt', descending: false)
          .get();
      for (final doc in snapshot.docs) {
        list.add(ProductModel.fromJson(doc.data()));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MenuCacheRepository] firestore fallback failed: $e');
      }
    }
    return list;
  }

  Future<_CachedMenu?> _readPersistent(String vendorId) async {
    try {
      await _dir();
      final file = File(_filePath(vendorId));
      if (!await file.exists()) return null;
      final raw = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final productsJson = (raw['products'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final products = productsJson
          .map((e) => ProductModel.fromJson(_deserializeProductMap(e)))
          .toList();
      return _CachedMenu(
        vendorId: vendorId,
        products: products,
        cachedAt: DateTime.tryParse(raw['cachedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        menuVersion: raw['menuVersion'] is int
            ? raw['menuVersion'] as int
            : int.tryParse(raw['menuVersion']?.toString() ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writePersistent(_CachedMenu cached) async {
    try {
      await _dir();
      final file = File(_filePath(cached.vendorId));
      final payload = <String, dynamic>{
        'vendorId': cached.vendorId,
        'cachedAt': cached.cachedAt.toIso8601String(),
        'menuVersion': cached.menuVersion,
        'products':
            cached.products.map((p) => _serializeProductMap(p.toJson())).toList(),
      };
      await file.writeAsString(jsonEncode(payload));
    } catch (_) {}
  }

  Future<void> invalidate(String vendorId) async {
    _memoryCache.remove(vendorId);
    try {
      await _dir();
      final file = File(_filePath(vendorId));
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static Map<String, dynamic> _serializeProductMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    map.forEach((key, value) {
      out[key] = _encodeValue(value);
    });
    return out;
  }

  static Map<String, dynamic> _deserializeProductMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    map.forEach((key, value) {
      out[key] = _decodeValue(value);
    });
    return out;
  }

  static dynamic _encodeValue(dynamic value) {
    if (value is Timestamp) {
      return <String, dynamic>{
        '__type': 'timestamp',
        'seconds': value.seconds,
        'nanoseconds': value.nanoseconds,
      };
    }
    if (value is DateTime) {
      return <String, dynamic>{
        '__type': 'datetime',
        'iso': value.toIso8601String(),
      };
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _encodeValue(v)));
    }
    if (value is List) {
      return value.map(_encodeValue).toList();
    }
    return value;
  }

  static dynamic _decodeValue(dynamic value) {
    if (value is Map) {
      final type = value['__type'];
      if (type == 'timestamp') {
        return Timestamp(
          value['seconds'] as int? ?? 0,
          value['nanoseconds'] as int? ?? 0,
        );
      }
      if (type == 'datetime') {
        return Timestamp.fromDate(
            DateTime.tryParse(value['iso']?.toString() ?? '') ?? DateTime.now());
      }
      return value.map((k, v) => MapEntry(k.toString(), _decodeValue(v)));
    }
    if (value is List) {
      return value.map(_decodeValue).toList();
    }
    return value;
  }
}

class _CachedMenu {
  _CachedMenu({
    required this.vendorId,
    required this.products,
    required this.cachedAt,
    this.menuVersion,
  });

  final String vendorId;
  final List<ProductModel> products;
  final DateTime cachedAt;
  final int? menuVersion;

  bool isValid({int? menuVersion}) {
    if (menuVersion != null) {
      if (this.menuVersion != null) {
        return this.menuVersion == menuVersion;
      }
      return false;
    }
    return DateTime.now().difference(cachedAt) < MenuCacheRepository.cacheTtl;
  }
}
