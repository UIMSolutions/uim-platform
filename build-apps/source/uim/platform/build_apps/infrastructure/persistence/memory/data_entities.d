/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryDataEntityRepository : DataEntityRepository {
    private DataEntity[] store;

    bool existsById(DataEntityId id) {
        return store.any!(e => e.id == id);
    }

    DataEntity findById(DataEntityId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return DataEntity.init;
    }

    DataEntity[] findAll() { return store; }

    DataEntity[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    DataEntity[] findByApplication(ApplicationId applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    void save(DataEntity entity) { store ~= entity; }

    void update(DataEntity entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(DataEntityId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
