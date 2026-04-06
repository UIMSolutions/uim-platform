/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.specifications;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemorySpecificationRepository : SpecificationRepository {
    private Specification[] store;

    Specification[] findAll() { return store; }

    Specification* findById(SpecificationId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Specification[] findByTenant(TenantId tenantId) {
        Specification[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Specification[] findByProduct(string productId) {
        Specification[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    Specification[] findByType(SpecificationType specType) {
        Specification[] result;
        foreach (ref e; store)
            if (e.specificationType == specType) result ~= e;
        return result;
    }

    void save(Specification spec) { store ~= spec; }

    void update(Specification spec) {
        foreach (ref e; store)
            if (e.id == spec.id) { e = spec; return; }
    }

    void remove(SpecificationId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
