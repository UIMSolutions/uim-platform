/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.dev_spaces;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryDevSpaceRepository : DevSpaceRepository {
    private DevSpace[] store;

    bool existsById(DevSpaceId id) {
        return store.any!(e => e.id == id);
    }

    DevSpace findById(DevSpaceId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return DevSpace.init;
    }

    DevSpace[] findAll() { return store; }

    DevSpace[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    DevSpace[] findByOwner(string owner) {
        return store.filter!(e => e.owner == owner).array;
    }

    DevSpace[] findByStatus(DevSpaceStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(DevSpace entity) { store ~= entity; }

    void update(DevSpace entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(DevSpaceId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
