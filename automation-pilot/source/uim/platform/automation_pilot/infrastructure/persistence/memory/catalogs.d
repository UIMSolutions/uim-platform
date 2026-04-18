/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCatalogRepository : CatalogRepository {
    private Catalog[] store;

    bool existsById(CatalogId id) {
        return store.any!(e => e.id == id);
    }

    Catalog findById(CatalogId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return Catalog.init;
    }

    Catalog[] findAll() { return store; }

    Catalog[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    Catalog[] findByStatus(CatalogStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    Catalog[] findByType(CatalogType catalogType) {
        return store.filter!(e => e.catalogType == catalogType).array;
    }

    void save(Catalog catalog) { store ~= catalog; }

    void update(Catalog catalog) {
        foreach (ref e; store)
            if (e.id == catalog.id) { e = catalog; return; }
    }

    void remove(CatalogId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
