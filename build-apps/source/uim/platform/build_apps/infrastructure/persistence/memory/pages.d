/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryPageRepository : PageRepository {
    private Page[] store;

    bool existsById(PageId id) {
        return store.any!(e => e.id == id);
    }

    Page findById(PageId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Page.init;
    }

    Page[] findAll() { return store; }

    Page[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Page[] findByApplication(ApplicationId applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    void save(Page entity) { store ~= entity; }

    void update(Page entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(PageId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
