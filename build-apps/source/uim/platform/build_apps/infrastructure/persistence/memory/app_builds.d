/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryAppBuildRepository : TenantRepository!(AppBuild, AppBuildId), AppBuildRepository {

    size_t countByApplication(ApplicationId applicationId) {
        return findByApplication(applicationId).length;
    }

    AppBuild[] findByApplication(ApplicationId applicationId) {
        return findAll.filter!(e => e.applicationId == applicationId).array;
    }

    void removeByApplication(ApplicationId applicationId) {
        findByApplication(applicationId).each!(e => remove(e));
    }

    size_t countByBuildStatus(BuildStatus status) {
        return findByBuildStatus(status).length;
    }

    AppBuild[] findByBuildStatus(BuildStatus status) {
        return findAll.filter!(e => e.buildStatus == status).array;
    }

    void removeByBuildStatus(BuildStatus status) {
        findByBuildStatus(status).each!(e => remove(e));
    }

}
