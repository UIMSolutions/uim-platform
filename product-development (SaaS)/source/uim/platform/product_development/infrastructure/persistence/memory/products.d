/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.products;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryProductRepository : ProductRepository {
    private Product[] store;

    Product[] findAll() { return store; }

    Product* findById(ProductId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Product[] findByTenant(TenantId tenantId) {
        Product[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Product[] findByType(ProductType productType) {
        Product[] result;
        foreach (ref e; store)
            if (e.productType == productType) result ~= e;
        return result;
    }

    Product[] findByStatus(ProductStatus status) {
        Product[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    Product[] findByLifecyclePhase(LifecyclePhase phase) {
        Product[] result;
        foreach (ref e; store)
            if (e.lifecyclePhase == phase) result ~= e;
        return result;
    }

    void save(Product product) { store ~= product; }

    void update(Product product) {
        foreach (ref e; store)
            if (e.id == product.id) { e = product; return; }
    }

    void remove(ProductId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
