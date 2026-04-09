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

class MemoryAppVersionRepository : AppVersionRepository {
  private AppVersion[AppVersionId] store;

  AppVersion findById(AppVersionId id) {
    if (auto p = id in store)
      return *p;
    return AppVersion.init;
  }

  AppVersion findLatest(MobileAppId appId, AppPlatform platform) {
    AppVersion latest = AppVersion.init;
    bool found = false;
    foreach (ref v; store) {
      if (v.appId == appId && v.platform == platform) {
        if (!found || v.publishedAt > latest.publishedAt) {
          latest = v;
          found = true;
        }
      }
    }
    return latest;
  }

  AppVersion[] findByApp(MobileAppId appId) {
    return store.values.filter!(v => v.appId == appId).array;
  }

  AppVersion[] findByStatus(MobileAppId appId, VersionStatus status) {
    return store.values.filter!(v => v.appId == appId && v.status == status).array;
  }

  AppVersion[] findByTenant(TenantId tenantId) {
    return store.values.filter!(v => v.tenantId == tenantId).array;
  }

  void save(AppVersion ver) {
    store[ver.id] = ver;
  }

  void update(AppVersion ver) {
    store[ver.id] = ver;
  }

  void remove(AppVersionId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return cast(long) store.values.filter!(v => v.appId == appId).array.length;
  }
}
