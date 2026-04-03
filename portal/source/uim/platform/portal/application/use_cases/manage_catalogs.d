module application.usecases.manage_catalogs;

import domain.entities.catalog;
import domain.types;
import domain.ports.catalog_repository;
import uim.platform.xyz.application.dto;

import std.uuid;
import std.datetime.systime : Clock;

class ManageCatalogsUseCase
{
    private CatalogRepository catalogRepo;

    this(CatalogRepository catalogRepo)
    {
        this.catalogRepo = catalogRepo;
    }

    CatalogResponse createCatalog(CreateCatalogRequest req)
    {
        if (req.title.length == 0)
            return CatalogResponse("", "Catalog title is required");

        auto now = Clock.currStdTime();
        auto id = randomUUID().toString();
        auto catalog = Catalog(
            id,
            req.tenantId,
            req.title,
            req.description,
            req.providerId,
            [],  // tileIds
            req.allowedRoleIds,
            req.active,
            now,
            now,
        );
        catalogRepo.save(catalog);
        return CatalogResponse(id, "");
    }

    Catalog getCatalog(CatalogId id)
    {
        return catalogRepo.findById(id);
    }

    Catalog[] listCatalogs(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        return catalogRepo.findByTenant(tenantId, offset, limit);
    }

    string updateCatalog(UpdateCatalogRequest req)
    {
        auto catalog = catalogRepo.findById(req.catalogId);
        if (catalog == Catalog.init)
            return "Catalog not found";

        catalog.title = req.title.length > 0 ? req.title : catalog.title;
        catalog.description = req.description;
        catalog.allowedRoleIds = req.allowedRoleIds;
        catalog.active = req.active;
        catalog.updatedAt = Clock.currStdTime();
        catalogRepo.update(catalog);
        return "";
    }

    string deleteCatalog(CatalogId id)
    {
        auto catalog = catalogRepo.findById(id);
        if (catalog == Catalog.init)
            return "Catalog not found";

        catalogRepo.remove(id);
        return "";
    }
}
