/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.change_requests;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryChangeRequestRepository : ChangeRequestRepository {
    private ChangeRequest[] store;

    ChangeRequest[] findAll() { return store; }

    ChangeRequest* findById(ChangeRequestId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    ChangeRequest[] findByTenant(TenantId tenantId) {
        ChangeRequest[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    ChangeRequest[] findByProduct(string productId) {
        ChangeRequest[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    ChangeRequest[] findByStatus(ChangeRequestStatus status) {
        ChangeRequest[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    ChangeRequest[] findByAssignee(string assignedTo) {
        ChangeRequest[] result;
        foreach (ref e; store)
            if (e.assignedTo == assignedTo) result ~= e;
        return result;
    }

    void save(ChangeRequest cr) { store ~= cr; }

    void update(ChangeRequest cr) {
        foreach (ref e; store)
            if (e.id == cr.id) { e = cr; return; }
    }

    void remove(ChangeRequestId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
