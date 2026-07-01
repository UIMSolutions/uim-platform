/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.app_builds;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

interface AppBuildRepository : ITenantRepository!(AppBuild, AppBuildId) {
    
    size_t countByApplication(TenantId tenantId, ApplicationId applicationId);
    AppBuild[] findByApplication(TenantId tenantId, ApplicationId applicationId);
    void removeByApplication(TenantId tenantId, ApplicationId applicationId);
    
    size_t countByBuildStatus(TenantId tenantId, BuildStatus status);
    AppBuild[] findByBuildStatus(TenantId tenantId, BuildStatus status);
    void removeByBuildStatus(TenantId tenantId, BuildStatus status);

}
