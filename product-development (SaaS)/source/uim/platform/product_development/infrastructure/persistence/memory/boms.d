/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.boms;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryBomRepository : BillOfMaterialRepository {
    private BillOfMaterial[] store;

    BillOfMaterial[] findAll() { return store; }

    BillOfMaterial* findById(BillOfMaterialId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    BillOfMaterial[] findByTenant(TenantId tenantId) {
        BillOfMaterial[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    BillOfMaterial[] findByProduct(string productId) {
        BillOfMaterial[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    BillOfMaterial[] findByType(BomType bomType) {
        BillOfMaterial[] result;
        foreach (ref e; store)
            if (e.bomType == bomType) result ~= e;
        return result;
    }

    void save(BillOfMaterial bom) { store ~= bom; }

    void update(BillOfMaterial bom) {
        foreach (ref e; store)
            if (e.id == bom.id) { e = bom; return; }
    }

    void remove(BillOfMaterialId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
