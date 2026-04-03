/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.offline_store;

import uim.platform.mobile.domain.types;

struct OfflineStore {
  OfflineStoreId id;
  TenantId tenantId;
  MobileAppId appId;
  string name;
  string serviceUrl;         // backend OData service URL
  string definingRequests;   // JSON array of defining requests
  OfflineStoreType storeType;
  SyncStatus syncStatus;
  long lastSyncAt;
  long sizeBytes;
  long createdAt;
  long updatedAt;
  string createdBy;
}
