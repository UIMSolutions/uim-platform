/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.offline_store;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

struct OfflineStore {
  mixin TenantEntity!(OfflineStoreId);

  MobileAppId appId;
  string name;
  string serviceUrl;         // backend OData service URL
  string definingRequests;   // JSON array of defining requests
  OfflineStoreType storeType;
  string description;
  SyncStatus syncStatus;
  long lastSyncAt;
  size_t sizeBytes;

  Json toJson() const {
    return entityToJson
      .set("appId", appId.value)
      .set("name", name)
      .set("description", description)
      .set("serviceUrl", serviceUrl)
      .set("definingRequests", definingRequests)
      .set("storeType", storeType)
      .set("syncStatus", syncStatus)
      .set("lastSyncAt", lastSyncAt)
      .set("sizeBytes", sizeBytes);

  }
}
