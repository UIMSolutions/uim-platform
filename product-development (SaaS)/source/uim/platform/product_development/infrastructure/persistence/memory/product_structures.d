/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.product_structures;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryProductStructureRepository : ProductStructureRepository {
    private ProductStructure[] store;

    ProductStructure[] findAll() { return store; }

    ProductStructure* findById(ProductStructureId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    ProductStructure[] findByTenant(TenantId tenantId) {
        ProductStructure[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    ProductStructure[] findByProduct(string productId) {
        ProductStructure[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    ProductStructure[] findByParent(string parentNodeId) {
        ProductStructure[] result;
        foreach (ref e; store)
            if (e.parentNodeId == parentNodeId) result ~= e;
        return result;
    }

    void save(ProductStructure ps) { store ~= ps; }

    void update(ProductStructure ps) {
        foreach (ref e; store)
            if (e.id == ps.id) { e = ps; return; }
    }

    void remove(ProductStructureId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
