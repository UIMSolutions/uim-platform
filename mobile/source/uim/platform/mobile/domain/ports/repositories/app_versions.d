/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.app_versions;

import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.types;

interface AppVersionRepository {
  AppVersion findById(AppVersionId id);
  AppVersion findLatest(MobileAppId appId, AppPlatform platform);
  AppVersion[] findByApp(MobileAppId appId);
  AppVersion[] findByStatus(MobileAppId appId, VersionStatus status);
  AppVersion[] findByTenant(TenantId tenantId);
  void save(AppVersion ver);
  void update(AppVersion ver);
  void remove(AppVersionId id);
  long countByApp(MobileAppId appId);
}
