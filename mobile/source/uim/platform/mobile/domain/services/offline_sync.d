/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.services.offline_sync_service;

import uim.platform.mobile.domain.types;

struct OfflineSyncService {
  // Validate a defining request URL pattern
  static bool validateDefiningRequest(string request) {
    return request.length > 0 && request.length <= 2048;
  }

  // Check if sync is needed based on last sync time and interval
  static bool isSyncNeeded(long lastSyncAt, long currentTime, long syncIntervalMs) {
    if (lastSyncAt == 0)
      return true; // never synced
    return (currentTime - lastSyncAt) >= syncIntervalMs;
  }

  // Validate store name
  static bool validateStoreName(string name) {
    if (name.length == 0 || name.length > 100)
      return false;
    import std.regex : regex, matchAll;

    auto pat = regex(`^[a-zA-Z0-9_\-.:]+$`);
    auto m = matchAll(name, pat);
    return !m.empty;
  }

  // Estimate store size from defining requests
  static long estimateStoreSize(long entityCount, long avgEntitySizeBytes) {
    return entityCount * avgEntitySizeBytes;
  }

  // Validate service URL
  static bool validateServiceUrl(string url) {
    return url.length > 0 && url.length <= 2048;
  }
}
