import 'package:flutter/foundation.dart';

/// Debug counters for restaurant menu / settings cache (parity with customer).
class FirestoreCacheMetrics {
  FirestoreCacheMetrics._();

  static int menuCacheHits = 0;
  static int menuCacheMisses = 0;
  static int menuFetches = 0;
  static int menuDedupedRequests = 0;

  static void log(String event, {Map<String, Object?>? data}) {
    if (!kDebugMode) return;
    debugPrint('[FirestoreCacheMetrics] $event ${data ?? {}}');
  }
}
