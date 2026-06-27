/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.app_versions;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface AppVersionRepository : ITentRepository!(AppVersion, AppVersionId) {

  bool existsLatest(TenantId tenantId, MobileAppId appId, AppPlatform platform);
  AppVersion findLatest(TenantId tenantId, MobileAppId appId, AppPlatform platform);
  void removeLatest(TenantId tenantId, MobileAppId appId, AppPlatform platform);

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  AppVersion[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByStatus(TenantId tenantId, MobileAppId appId, VersionStatus status);
  AppVersion[] findByStatus(TenantId tenantId, MobileAppId appId, VersionStatus status);
  void removeByStatus(TenantId tenantId, MobileAppId appId, VersionStatus status);

}
