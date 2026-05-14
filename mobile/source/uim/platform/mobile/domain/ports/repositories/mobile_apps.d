/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.mobile_apps;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

interface MobileAppRepository : ITenantRepository!(MobileApp, MobileAppId) {

  size_t countByBundleId(TenantId tenantId, string bundleId);
  MobileApp findByBundleId(TenantId tenantId, string bundleId);
  void removeByBundleId(TenantId tenantId, string bundleId);

  size_t countByPlatform(TenantId tenantId, AppPlatform platform);
  MobileApp[] findByPlatform(TenantId tenantId, AppPlatform platform);
  void removeByPlatform(TenantId tenantId, AppPlatform platform);

}
