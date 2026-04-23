/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.offline_stores;

import uim.platform.mobile.domain.entities.offline_store;
import uim.platform.mobile.domain.types;

interface OfflineStoreRepository : ITenantRepository!(OfflineStore, OfflineStoreId) {

  size_t countByApp(MobileAppId appId);
  OfflineStore[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

}
