/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryProjectRepository : TenantRepository!(Project, ProjectId), ProjectRepository {

    size_t countByType(TenantId tenantId, ProjectType projectType) {
        return findByType(tenantId, projectType).length;
    }

Project[] filterByType(Project[] projects, ProjectType projectType) {
        return projects.filter!(p => p.projectType == projectType).array;
    }

    Project[] findByType(TenantId tenantId, ProjectType projectType) {
        return filterByType(findByTenant(tenantId), projectType);
    }

    void removeByType(TenantId tenantId, ProjectType projectType) {
        findByType(tenantId, projectType).each!(e => remove(e));
    }


    size_t countByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return findByDevSpace(tenantId, devSpaceId).length;
    }

    Project[] filterByDevSpace(Project[] projects, DevSpaceId devSpaceId) {
        return projects.filter!(p => p.devSpaceId == devSpaceId).array;
    }

    Project[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        return filterByDevSpace(findByTenant(tenantId), devSpaceId);
    }

    void removeByDevSpace(TenantId tenantId, DevSpaceId devSpaceId) {
        findByDevSpace(tenantId, devSpaceId).each!(e => remove(e));
    }

}
