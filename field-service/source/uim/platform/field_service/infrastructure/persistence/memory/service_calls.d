/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.service_calls;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryServiceCallRepository : ServiceCallRepository {
    private ServiceCall[] store;

    bool existsById(ServiceCallId id) {
        return store.any!(e => e.id == id);
    }

    ServiceCall findById(ServiceCallId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ServiceCall.init; // or throw an exception
    }

    ServiceCall[] findAll() { return store; }

    ServiceCall[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ServiceCall[] findByStatus(ServiceCallStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    ServiceCall[] findByPriority(ServiceCallPriority priority) {
        return store.filter!(e => e.priority == priority).array;
    }

    ServiceCall[] findByCustomer(CustomerId customerId) {
        return store.filter!(e => e.customerId == customerId).array;
    }

    void save(ServiceCall serviceCall) { store ~= serviceCall; }

    void update(ServiceCall serviceCall) {
        foreach (e; store)
            if (e.id == serviceCall.id) { e = serviceCall; return; }
    }

    void remove(ServiceCallId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
