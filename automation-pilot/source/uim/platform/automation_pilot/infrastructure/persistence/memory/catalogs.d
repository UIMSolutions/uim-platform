/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCatalogRepository : TenantRepository!(Catalog, CatalogId), CatalogRepository {

    size_t countByStatus(CatalogStatus status) {
        return findByStatus(status).length;
    }

    Catalog[] findByStatus(CatalogStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void removeByStatus(CatalogStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

    size_t countByType(CatalogType catalogType) {
        return findByType(catalogType).length;
    }

    Catalog[] findByType(CatalogType catalogType) {
        return findAll().filter!(e => e.catalogType == catalogType).array;
    }

    void removeByType(CatalogType catalogType) {
        findByType(catalogType).each!(e => remove(e));
    }
}
