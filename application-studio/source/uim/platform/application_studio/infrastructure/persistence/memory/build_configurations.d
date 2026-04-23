/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryBuildConfigurationRepository : TenantRepository!(BuildConfiguration, BuildConfigurationId), BuildConfigurationRepository {

    size_t countByProject(ProjectId projectId) {
        return findByProject(projectId).length;
    }   

    BuildConfiguration[] findByProject(ProjectId projectId) {
        return findAll().filter!(e => e.projectId == projectId).array;
    }

    void removeByProject(ProjectId projectId) {
        findByProject(projectId).each!(e => remove(e.id));
    }

    size_t countByStatus(BuildStatus status) {
        return findByStatus(status).length;
    }

    BuildConfiguration[] findByStatus(BuildStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(BuildStatus status) {
        findByStatus(status).each!(e => remove(e.id));
    }
}
