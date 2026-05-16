/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.repositories.catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface CatalogRepository : ITenantRepository!(Catalog, CatalogId) {

    size_t countByStatus(TenantId tenantId, CatalogStatus status);
    Catalog[] findByStatus(TenantId tenantId, CatalogStatus status);
    void removeByStatus(TenantId tenantId, CatalogStatus status);

    size_t countByType(TenantId tenantId, CatalogType catalogType);
    Catalog[] findByType(TenantId tenantId, CatalogType catalogType);
    void removeByType(CatalogType catalogType);

}
