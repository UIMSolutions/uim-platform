/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageAppBuildsUseCase { 
    
    AppBuild getAppBuild(TenantId tenantId, AppBuildId id);
    AppBuild[] listAppBuilds(TenantId tenantId);
    AppBuild[] listAppBuilds(TenantId tenantId, ApplicationId applicationId);
    UsecaseResult createAppBuild(AppBuildDTO dto);
    UsecaseResult updateAppBuild(AppBuildDTO dto);
    UsecaseResult deleteAppBuild(TenantId tenantId, AppBuildId id);
    
}
