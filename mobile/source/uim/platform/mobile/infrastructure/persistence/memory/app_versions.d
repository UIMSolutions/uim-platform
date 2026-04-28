/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.app_version;

import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.ports.repositories.app_versions;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryAppVersionRepository : TenantRepository!(AppVersion, AppVersionId), AppVersionRepository {

  AppVersion findLatest(MobileAppId appId, AppPlatform platform) {
    AppVersion latest = AppVersion.init;
    bool found = false;
    foreach (v; findAll) {
      if (v.appId == appId && v.platform == platform) {
        if (!found || v.publishedAt > latest.publishedAt) {
          latest = v;
          found = true;
        }
      }
    }
    return latest;
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }

  AppVersion[] filterByApp(AppVersion[] versions, MobileAppId appId) {
    return versions.filter!(v => v.appId == appId).array;
  }

  AppVersion[] findByApp(MobileAppId appId) {
    return filterByApp(findAll(), appId);
  }

  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(v => remove(v));
  }

  size_t countByStatus(MobileAppId appId, VersionStatus status) {
    return findByStatus(appId, status).length;
  }
  AppVersion[] filterByStatus(AppVersion[] versions, VersionStatus status) {
    return versions.filter!(v => v.status == status).array;
  }
  AppVersion[] findByStatus(MobileAppId appId, VersionStatus status) {
    return filterByStatus(findByApp(appId), status);
  }
  void removeByStatus(MobileAppId appId, VersionStatus status) {
    findByStatus(appId, status).each!(v => remove(v));
  }

}
