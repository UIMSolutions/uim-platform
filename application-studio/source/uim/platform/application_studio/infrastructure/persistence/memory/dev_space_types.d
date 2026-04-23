/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.persistence.memory.dev_space_types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class MemoryDevSpaceTypeRepository : DevSpaceTypeRepository {
    private DevSpaceType[] store;

    bool existsById(DevSpaceTypeId id) {
        return store.any!(e => e.id == id);
    }

    DevSpaceType findById(DevSpaceTypeId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return DevSpaceType.init;
    }

    DevSpaceType[] findAll() { return store; }

    DevSpaceType[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    DevSpaceType[] findByCategory(DevSpaceTypeCategory category) {
        return findAll().filter!(e => e.category == category).array;
    }

    void save(DevSpaceType entity) { store ~= entity; }

    void update(DevSpaceType entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(DevSpaceTypeId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
