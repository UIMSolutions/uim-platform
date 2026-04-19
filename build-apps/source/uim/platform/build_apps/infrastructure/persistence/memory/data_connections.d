/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.infrastructure.persistence.memory.data_connections;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class MemoryDataConnectionRepository : DataConnectionRepository {
    private DataConnection[] store;

    bool existsById(DataConnectionId id) {
        return store.any!(e => e.id == id);
    }

    DataConnection findById(DataConnectionId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return DataConnection.init;
    }

    DataConnection[] findAll() { return store; }

    DataConnection[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    DataConnection[] findByApplication(ApplicationId applicationId) {
        return store.filter!(e => e.applicationId == applicationId).array;
    }

    DataConnection[] findByType(ConnectionType type) {
        return store.filter!(e => e.type == type).array;
    }

    void save(DataConnection entity) { store ~= entity; }

    void update(DataConnection entity) {
        foreach (ref e; store)
            if (e.id == entity.id) { e = entity; return; }
    }

    void remove(DataConnectionId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
