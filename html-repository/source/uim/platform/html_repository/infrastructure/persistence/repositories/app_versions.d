/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.infrastructure.persistence.repositories.app_versions;

// import uim.platform.html_repository.domain.ports.repositories.app_versions;
// import uim.platform.html_repository.domain.entities.app_version;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppVersionRepository : TenantRepository!(AppVersion, AppVersionId), IAppVersionRepository {

  AppVersion findLatest(TenantId tenantId, HtmlAppId appId) {
    AppVersion latest = AppVersion.init;
    bool found = false;
    foreach (e; findByTenant(tenantId)) {
      if (e.appId == appId) {
        if (!found || e.createdAt > latest.createdAt) {
          latest = e;
          found = true;
        }
      }
    }
    return latest;
  }

  void removeLatest(TenantId tenantId, HtmlAppId appId) {
    AppVersion latest = findLatest(tenantId, appId);
    if (latest.id != AppVersionId.init) {
      remove(latest);
    }
  }

  size_t countByApp(TenantId tenantId, HtmlAppId appId) {
    return findByApp(tenantId, appId).length;
  }
  AppVersion[] filterByApp(AppVersion[] versions, HtmlAppId appId) {
    return versions.filter!(v => v.appId == appId).array;
  }
  AppVersion[] findByApp(TenantId tenantId, HtmlAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }
  void removeByApp(TenantId tenantId, HtmlAppId appId) {
    findByApp(tenantId, appId).each!(v => remove(v));
  }

  size_t countByStatus(TenantId tenantId, HtmlAppId appId, VersionStatus status) {
    return findByStatus(tenantId, appId, status).length;
  }
  AppVersion[] filterByStatus(AppVersion[] versions, HtmlAppId appId, VersionStatus status) {
    return filterByApp(versions, appId).filter!(v => v.status == status).array;
  } 
  AppVersion[] findByStatus(TenantId tenantId, HtmlAppId appId, VersionStatus status) {
    return filterByStatus(findByTenant(tenantId), appId, status);
  }
  void removeByStatus(TenantId tenantId, HtmlAppId appId, VersionStatus status) {
    findByStatus(tenantId, appId, status).each!(v => remove(v));
  }

}
