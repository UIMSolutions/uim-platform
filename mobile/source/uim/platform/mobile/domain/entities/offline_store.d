/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.offline_store;

import uim.platform.mobile.domain.types;

struct OfflineStore {
  mixin TenantEntity!(OfflineStoreId);

  MobileAppId appId;
  string name;
  string serviceUrl;         // backend OData service URL
  string definingRequests;   // JSON array of defining requests
  OfflineStoreType storeType;
  SyncStatus syncStatus;
  long lastSyncAt;
  long sizeBytes;

  Json toJson() const {
    auto j = entityToJson
      .set("appId", appId.value)
      .set("name", name)
      .set("serviceUrl", serviceUrl)
      .set("definingRequests", definingRequests)
      .set("storeType", storeType)
      .set("syncStatus", syncStatus)
      .set("lastSyncAt", lastSyncAt)
      .set("sizeBytes", sizeBytes);

    return j;
  }
}
