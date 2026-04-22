/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.mobile_apps;

import uim.platform.mobile.domain.entities.mobile_app;
import uim.platform.mobile.domain.types;

interface MobileAppRepository : ITenantRepository!(MobileApp, MobileAppId) {

  size_t countByBundleId(string bundleId);
  MobileApp findByBundleId(string bundleId);
  void removeByBundleId(string bundleId);

  size_t countByPlatform(TenantId tenantId, AppPlatform platform);
  MobileApp[] findByPlatform(TenantId tenantId, AppPlatform platform);
  void removeByPlatform(TenantId tenantId, AppPlatform platform);

}
