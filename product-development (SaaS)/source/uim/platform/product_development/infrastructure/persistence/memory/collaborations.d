/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.collaborations;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryCollaborationRepository : CollaborationRepository {
    private Collaboration[] store;

    Collaboration[] findAll() { return store; }

    Collaboration* findById(CollaborationId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Collaboration[] findByTenant(TenantId tenantId) {
        Collaboration[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Collaboration[] findByProduct(string productId) {
        Collaboration[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    Collaboration[] findByStatus(CollaborationStatus status) {
        Collaboration[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    Collaboration[] findByAssignee(string assignedTo) {
        Collaboration[] result;
        foreach (ref e; store)
            if (e.assignedTo == assignedTo) result ~= e;
        return result;
    }

    void save(Collaboration collab) { store ~= collab; }

    void update(Collaboration collab) {
        foreach (ref e; store)
            if (e.id == collab.id) { e = collab; return; }
    }

    void remove(CollaborationId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
