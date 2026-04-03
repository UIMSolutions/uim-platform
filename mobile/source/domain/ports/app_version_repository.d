/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.app_version_repository;

import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.types;

/// Port: outgoing — app version persistence.
interface AppVersionRepository
{
  AppVersion findById(AppVersionId id);
  AppVersion[] findByApp(MobileAppId appId);
  AppVersion[] findByAppAndPlatform(MobileAppId appId, MobilePlatform platform);
  AppVersion findLatestReleased(MobileAppId appId, MobilePlatform platform);
  void save(AppVersion version_);
  void update(AppVersion version_);
  void remove(AppVersionId id);
}
