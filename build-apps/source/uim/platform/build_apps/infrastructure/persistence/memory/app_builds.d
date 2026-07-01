/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.app_builds;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class MemoryAppBuildRepository : TenantRepository!(AppBuild, AppBuildId), AppBuildRepository {

  size_t countByApplication(TenantId tenantId, ApplicationId applicationId) {
    return findByApplication(tenantId, applicationId).length;
  }

  AppBuild[] filterByApplication(AppBuild[] builds, ApplicationId applicationId) {
    return builds.filter!(e => e.applicationId == applicationId).array;
  }

  AppBuild[] findByApplication(TenantId tenantId, ApplicationId applicationId) {
    return filterByApplication(findByTenant(tenantId), applicationId);
  }

  void removeByApplication(TenantId tenantId, ApplicationId applicationId) {
    findByApplication(tenantId, applicationId).each!(e => remove(e));
  }

  size_t countByBuildStatus(TenantId tenantId, BuildStatus status) {
    return findByBuildStatus(tenantId, status).length;
  }

  AppBuild[] filterByBuildStatus(AppBuild[] builds, BuildStatus status) {
    return builds.filter!(e => e.buildStatus == status).array;
  }

  AppBuild[] findByBuildStatus(TenantId tenantId, BuildStatus status) {
    return filterByBuildStatus(findByTenant(tenantId), status);
  }

  void removeByBuildStatus(TenantId tenantId, BuildStatus status) {
    findByBuildStatus(tenantId, status).each!(e => remove(e));
  }

}
