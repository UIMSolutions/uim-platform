/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.ports.usecases.catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

interface IManageCatalogsUseCase { 
    
    Catalog getCatalog(TenantId tenantId, CatalogId id);
    Catalog[] listCatalogs(TenantId tenantId);
    Catalog[] listCatalogs(TenantId tenantId, CatalogStatus status);
    CommandResult createCatalog(CatalogDTO dto);
    CommandResult updateCatalog(CatalogDTO dto);
    CommandResult deleteCatalog(TenantId tenantId, CatalogId id);
    
}
