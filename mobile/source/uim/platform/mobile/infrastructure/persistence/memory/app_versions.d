/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.app_versions;
// import uim.platform.mobile.domain.entities.app_version;
// import uim.platform.mobile.domain.ports.repositories.app_versions;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryAppVersionRepository : TenantRepository!(AppVersion, AppVersionId), AppVersionRepository {

  AppVersion findLatest(TenantId tenantId, MobileAppId appId, AppPlatform platform) {
    AppVersion latest = AppVersion.init;
    bool found = false;
    foreach (v; findByTenant(tenantId)) {
      if (v.appId == appId && v.platform == platform) {
        if (!found || v.publishedAt > latest.publishedAt) {
          latest = v;
          found = true;
        }
      }
    }
    return latest;
  }

  // #region ByApp
  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  AppVersion[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(v => remove(v));
  }
  // #endregion ByApp

  size_t countByStatus(TenantId tenantId, MobileAppId appId, VersionStatus status) {
    return findByStatus(tenantId, appId, status).length;
  }
  AppVersion[] filterByStatus(AppVersion[] versions, VersionStatus status) {
    return versions.filter!(v => v.status == status).array;
  }
  AppVersion[] findByStatus(TenantId tenantId, MobileAppId appId, VersionStatus status) {
    return filterByStatus(findByApp(tenantId, appId), status);
  }
  void removeByStatus(TenantId tenantId, MobileAppId appId, VersionStatus status) {
    findByStatus(tenantId, appId, status).each!(v => remove(v));
  }

}
