/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.broker_services;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryBrokerServiceRepository : BrokerServiceRepository {
    private BrokerService[] store;

    bool existsById(BrokerServiceId id) {
        return store.any!(e => e.id == id);
    }

    BrokerService findById(BrokerServiceId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return BrokerService.init;
    }

    BrokerService[] findAll() { return store; }

    BrokerService[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    BrokerService[] findByStatus(BrokerServiceStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    BrokerService[] findByCloudProvider(CloudProvider provider) {
        return store.filter!(e => e.cloudProvider == provider).array;
    }

    void save(BrokerService service) { store ~= service; }

    void update(BrokerService service) {
        foreach (ref e; store)
            if (e.id == service.id) { e = service; return; }
    }

    void remove(BrokerServiceId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
