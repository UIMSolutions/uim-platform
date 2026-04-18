/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface CatalogRepository {
    bool existsById(CatalogId id);
    Catalog findById(CatalogId id);

    Catalog[] findAll();
    Catalog[] findByTenant(TenantId tenantId);
    Catalog[] findByStatus(CatalogStatus status);
    Catalog[] findByType(CatalogType catalogType);

    void save(Catalog catalog);
    void update(Catalog catalog);
    void remove(CatalogId id);
}
