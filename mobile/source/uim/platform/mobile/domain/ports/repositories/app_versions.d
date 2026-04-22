/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.app_versions;

import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.types;

interface AppVersionRepository : ITenantRepository!(AppVersion, AppVersionId) {

  bool existsLatest(MobileAppId appId, AppPlatform platform);
  AppVersion findLatest(MobileAppId appId, AppPlatform platform);
  void removeLatest(MobileAppId appId, AppPlatform platform);

  size_t countByApp(MobileAppId appId);
  AppVersion[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByStatus(MobileAppId appId, VersionStatus status);
  AppVersion[] findByStatus(MobileAppId appId, VersionStatus status);
  void removeByStatus(MobileAppId appId, VersionStatus status);

}
