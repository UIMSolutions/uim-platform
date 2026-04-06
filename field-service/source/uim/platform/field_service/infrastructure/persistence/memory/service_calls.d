module uim.platform.field_service.infrastructure.persistence.memory.service_calls;

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

    ServiceCall[] findAll() { return store; }

    ServiceCall* findById(ServiceCallId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    ServiceCall[] findByTenant(TenantId tenantId) {
        ServiceCall[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    ServiceCall[] findByStatus(ServiceCallStatus status) {
        ServiceCall[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    ServiceCall[] findByPriority(ServiceCallPriority priority) {
        ServiceCall[] result;
        foreach (ref e; store)
            if (e.priority == priority) result ~= e;
        return result;
    }

    ServiceCall[] findByCustomer(CustomerId customerId) {
        ServiceCall[] result;
        foreach (ref e; store)
            if (e.customerId == customerId) result ~= e;
        return result;
    }

    void save(ServiceCall serviceCall) { store ~= serviceCall; }

    void update(ServiceCall serviceCall) {
        foreach (ref e; store)
            if (e.id == serviceCall.id) { e = serviceCall; return; }
    }

    void remove(ServiceCallId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
