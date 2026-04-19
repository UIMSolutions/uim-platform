/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.repositories.app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface AppBuildRepository {
    bool existsById(AppBuildId id);
    AppBuild findById(AppBuildId id);

    AppBuild[] findAll();
    AppBuild[] findByTenant(TenantId tenantId);
    AppBuild[] findByApplication(ApplicationId applicationId);
    AppBuild[] findByBuildStatus(BuildStatus status);

    void save(AppBuild entity);
    void update(AppBuild entity);
    void remove(AppBuildId id);
}
