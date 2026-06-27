/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.build_configurations;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class MemoryBuildConfigurationRepository : TentRepository!(BuildConfiguration, BuildConfigurationId), BuildConfigurationRepository {

    size_t countByProject(TenantId tenantId, ProjectId projectId) {
        return findByProject(tenantId, projectId).length;
    }   

    BuildConfiguration[] findByProject(TenantId tenantId, ProjectId projectId) {
        return findByTenant(tenantId).filter!(e => e.projectId == projectId).array;
    }

    void removeByProject(TenantId tenantId, ProjectId projectId) {
        findByProject(tenantId, projectId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, BuildStatus status) {
        return findByStatus(tenantId, status).length;
    }

    BuildConfiguration[] findByStatus(TenantId tenantId, BuildStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, BuildStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }
}
