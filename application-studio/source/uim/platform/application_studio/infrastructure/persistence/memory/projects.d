/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.projects;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryProjectRepository : ProjectRepository {
    private Project[] store;

    bool existsById(ProjectId id) {
        return store.any!(e => e.id == id);
    }

    Project findById(ProjectId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Project.init;
    }

    Project[] findAll() { return store; }

    Project[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Project[] findByDevSpace(DevSpaceId devSpaceId) {
        return findAll().filter!(e => e.devSpaceId == devSpaceId).array;
    }

    Project[] findByType(ProjectType projectType) {
        return findAll().filter!(e => e.projectType == projectType).array;
    }

    void save(Project entity) { store ~= entity; }

    void update(Project entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(ProjectId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
