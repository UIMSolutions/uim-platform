/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.catalogs;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

class MemoryCatalogRepository : TenantRepository!(Catalog, CatalogId), CatalogRepository {

    size_t countByStatus(TenantId tenantId, CatalogStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Catalog[] findByStatus(TenantId tenantId, CatalogStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    Catalog[] filterByStatus(Catalog[] catalogs, CatalogStatus status) {
        return catalogs.filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, CatalogStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByType(TenantId tenantId, CatalogType catalogType) {
        return findByType(tenantId, catalogType).length;
    }

    Catalog[] findByType(TenantId tenantId, CatalogType catalogType) {
        return filterByType(find(tenantId), catalogType);
    }

    Catalog[] filterByType(Catalog[] catalogs, CatalogType catalogType) {
        return catalogs.filter!(e => e.catalogType == catalogType).array;
    }

    void removeByType(TenantId tenantId, CatalogType catalogType) {
        findByType(tenantId, catalogType).each!(e => remove(e));
    }
}
