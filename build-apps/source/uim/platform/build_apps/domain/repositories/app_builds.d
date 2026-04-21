/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface AppBuildRepository : ITenantRepository!(AppBuild, AppBuildId) {
    
    size_t countByApplication(ApplicationId applicationId);
    AppBuild[] findByApplication(ApplicationId applicationId);
    void removeByApplication(ApplicationId applicationId);
    
    size_t countByBuildStatus(BuildStatus status);
    AppBuild[] findByBuildStatus(BuildStatus status);
    void removeByBuildStatus(BuildStatus status);

}
