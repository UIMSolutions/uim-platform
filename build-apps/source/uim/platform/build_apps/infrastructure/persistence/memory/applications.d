/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryApplicationRepository : ApplicationRepository {
    private Application[] store;

    bool existsById(ApplicationId id) {
        return store.any!(e => e.id == id);
    }

    Application findById(ApplicationId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Application.init;
    }

    Application[] findAll() { return store; }

    Application[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    Application[] findByOwner(string owner) {
        return findAll().filter!(e => e.owner == owner).array;
    }

    Application[] findByStatus(ApplicationStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(Application entity) { store ~= entity; }

    void update(Application entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(ApplicationId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
