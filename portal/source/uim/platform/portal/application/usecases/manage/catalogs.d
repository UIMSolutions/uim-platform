/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.catalogs;

// import uim.platform.portal.domain.entities.catalog;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.catalogs;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageCatalogsUseCase : UIMUseCase {
  private CatalogRepository catalogRepo;

  this(CatalogRepository catalogRepo) {
    this.catalogRepo = catalogRepo;
  }

  CatalogResponse createCatalog(CreateCatalogRequest req) {
    if (req.title.length == 0)
      return CatalogResponse(CatalogId(""), "Catalog title is required");

    Catalog catalog;
    with (catalog) {
      tenantId = req.tenantId;
      catalogId = randomUUID();
      title = req.title;
      description = req.description;
      providerId = req.providerId;
      tileIds = [];
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array;
      active = req.active;
      createdAt = Clock.currStdTime();
      updatedAt = createdAt;
      }
      catalogRepo.save(catalog);
    return CatalogResponse(catalog.catalogId, "");
  }

  Catalog getCatalog(CatalogId id) {
    return catalogRepo.findById(id);
  }

  Catalog[] listCatalogs(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return catalogRepo.findByTenant(tenantId, offset, limit);
  }

  string updateCatalog(UpdateCatalogRequest req) {
    if (!catalogRepo.existsById(req.catalogId))
      return "Catalog not found";

    auto catalog = catalogRepo.findById(req.catalogId);
    catalog.title = req.title.length > 0 ? req.title : catalog.title;
    catalog.description = req.description;
    catalog.allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array;
    catalog.active = req.active;
    catalog.updatedAt = Clock.currStdTime();
    catalogRepo.update(catalog);
    return "";
  }

  string deleteCatalog(CatalogId id) {
    if (!catalogRepo.existsById(id))
      return "Catalog not found";

    catalogRepo.remove(id);
    return "";
  }
}
