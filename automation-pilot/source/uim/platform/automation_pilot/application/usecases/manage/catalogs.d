/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageCatalogsUseCase { // TODO: UIMUseCase {
    private CatalogRepository repo;

    this(CatalogRepository repo) {
        this.repo = repo;
    }

    Catalog getCatalog(TenantId tenantId, CatalogId id) {
        return repo.findById(tenantId, id);
    }

    Catalog[] listCatalogs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Catalog[] listCatalogs(TenantId tenantId, CatalogStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createCatalog(CatalogDTO dto) {
        auto c = Catalog(dto.tenantId, dto.catalogId.isNull ? CatalogId(createId) : dto.catalogId, dto.createdBy);
        c.name = dto.name;
        c.description = dto.description;
        c.tags = dto.tags;
        c.version_ = dto.version_;
        
        if (!AutomationValidator.isValidCatalog(c))
            return CommandResult(false, "", "Invalid catalog data");
        repo.save(c);
        return CommandResult(true, dto.catalogId.value, "");
    }

    CommandResult updateCatalog(CatalogDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.catalogId);
        if (existing.isNull)
            return CommandResult(false, "", "Catalog not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.tags.length > 0) existing.tags = dto.tags;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteCatalog(TenantId tenantId, CatalogId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Catalog not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
