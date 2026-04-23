/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.project_templates;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryProjectTemplateRepository : ProjectTemplateRepository {
    private ProjectTemplate[] store;

    bool existsById(ProjectTemplateId id) {
        return store.any!(e => e.id == id);
    }

    ProjectTemplate findById(ProjectTemplateId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ProjectTemplate.init;
    }

    ProjectTemplate[] findAll() { return store; }

    ProjectTemplate[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    ProjectTemplate[] findByCategory(TemplateCategory category) {
        return findAll().filter!(e => e.category == category).array;
    }

    void save(ProjectTemplate entity) { store ~= entity; }

    void update(ProjectTemplate entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(ProjectTemplateId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
