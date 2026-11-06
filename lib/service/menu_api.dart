import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant/firebase_options.dart';
import 'package:restaurant/models/product_model.dart';

/// Redis-backed owner menu API (Cloud Functions).
/// Includes unpublished products. Never connects to Redis directly.
class MenuApi {
  MenuApi._();

  static Uri _callableUri(String functionName) {
    final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
    return Uri.parse(
      'https://us-central1-$projectId.cloudfunctions.net/$functionName',
    );
  }

  /// Full restaurant catalog for the signed-in owner/employee.
  /// Returns null if the call fails (caller should fall back to Firestore).
  static Future<List<ProductModel>?> getOwnerMenu({
    required String vendorId,
    bool forceRefresh = false,
  }) async {
    if (vendorId.isEmpty) {
      return <ProductModel>[];
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return null;
      }
      final idToken = await user.getIdToken();

      final response = await http
          .post(
            _callableUri('getVendorOwnerMenu'),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'data': {
                'vendorId': vendorId,
                'forceRefresh': forceRefresh,
              },
            }),
          )
          .timeout(const Duration(seconds: 8));

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] != null) {
        if (kDebugMode) {
          debugPrint('[MenuApi] callable error: ${decoded['error']}');
        }
        return null;
      }
      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint(
              '[MenuApi] HTTP ${response.statusCode}: ${response.body}');
        }
        return null;
      }

      final result = decoded is Map ? decoded['result'] : null;
      if (result is! Map || result['ok'] != true) {
        return null;
      }

      final productsRaw = result['products'];
      final list = <ProductModel>[];
      if (productsRaw is List) {
        for (final item in productsRaw) {
          if (item is Map) {
            list.add(
              ProductModel.fromJson(
                _deserializeProductMap(Map<String, dynamic>.from(item)),
              ),
            );
          }
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[MenuApi] owner menu source=${result['source']} items=${list.length}',
        );
      }
      return list;
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[MenuApi] getOwnerMenu failed: $e\n$s');
      }
      return null;
    }
  }

  static Map<String, dynamic> _deserializeProductMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    map.forEach((key, value) {
      out[key] = _decodeValue(value);
    });
    return out;
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
          DateTime.tryParse(value['iso']?.toString() ?? '') ?? DateTime.now(),
        );
      }
      return value.map((k, v) => MapEntry(k.toString(), _decodeValue(v)));
    }
    if (value is List) {
      return value.map(_decodeValue).toList();
    }
    return value;
  }
}
