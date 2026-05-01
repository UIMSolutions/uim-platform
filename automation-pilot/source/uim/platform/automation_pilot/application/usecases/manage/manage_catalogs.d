/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.manage_catalogs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageCatalogsUseCase { // TODO: UIMUseCase {
    private CatalogRepository repo;

    this(CatalogRepository repo) {
        this.repo = repo;
    }

    Catalog getById(CatalogId id) {
        return repo.findById(id);
    }

    Catalog[] list() {
        return repo.findAll();
    }

    Catalog[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Catalog[] listByStatus(CatalogStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(CatalogDTO dto) {
        Catalog c;
        c.id = CatalogId(dto.id);
        c.tenantId = dto.tenantId;
        c.name = dto.name;
        c.description = dto.description;
        c.tags = dto.tags;
        c.version_ = dto.version_;
        c.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidCatalog(c))
            return CommandResult(false, "", "Invalid catalog data");
        repo.save(c);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(CatalogDTO dto) {
        if (!repo.existsById(CatalogId(dto.id)))
            return CommandResult(false, "", "Catalog not found");
        auto existing = repo.findById(CatalogId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.tags.length > 0) existing.tags = dto.tags;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(CatalogId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Catalog not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
