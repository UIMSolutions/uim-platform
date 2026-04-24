/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryRunConfigurationRepository : RunConfigurationRepository {
    private RunConfiguration[] store;

    bool existsById(RunConfigurationId id) {
        return store.any!(e => e.id == id);
    }

    RunConfiguration findById(RunConfigurationId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return RunConfiguration.init;
    }

    RunConfiguration[] findAll() { return store; }

    RunConfiguration[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    RunConfiguration[] findByProject(ProjectId projectId) {
        return findAll().filter!(e => e.projectId == projectId).array;
    }

    void save(RunConfiguration entity) { store ~= entity; }

    void update(RunConfiguration entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(RunConfigurationId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
