/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryBuildConfigurationRepository : BuildConfigurationRepository {
    private BuildConfiguration[] store;

    bool existsById(BuildConfigurationId id) {
        return store.any!(e => e.id == id);
    }

    BuildConfiguration findById(BuildConfigurationId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return BuildConfiguration.init;
    }

    BuildConfiguration[] findAll() { return store; }

    BuildConfiguration[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    BuildConfiguration[] findByProject(ProjectId projectId) {
        return findAll().filter!(e => e.projectId == projectId).array;
    }

    BuildConfiguration[] findByStatus(BuildStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(BuildConfiguration entity) { store ~= entity; }

    void update(BuildConfiguration entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(BuildConfigurationId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
