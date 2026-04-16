/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_applications;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryEventApplicationRepository : EventApplicationRepository {
    private EventApplication[] store;

    bool existsById(EventApplicationId id) {
        return store.any!(e => e.id == id);
    }

    EventApplication findById(EventApplicationId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return EventApplication.init;
    }

    EventApplication[] findAll() { return store; }

    EventApplication[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    EventApplication[] findByBrokerService(BrokerServiceId brokerServiceId) {
        return store.filter!(e => e.brokerServiceId == brokerServiceId).array;
    }

    EventApplication[] findByStatus(EventApplicationStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    EventApplication[] findByType(EventApplicationType appType) {
        return store.filter!(e => e.applicationType == appType).array;
    }

    void save(EventApplication application) { store ~= application; }

    void update(EventApplication application) {
        foreach (ref e; store)
            if (e.id == application.id) { e = application; return; }
    }

    void remove(EventApplicationId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
