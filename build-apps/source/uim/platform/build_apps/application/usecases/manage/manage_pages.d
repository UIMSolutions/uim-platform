/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.manage_pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManagePagesUseCase { // TODO: UIMUseCase {
    private PageRepository repo;

    this(PageRepository repo) {
        this.repo = repo;
    }

    Page getById(PageId id) {
        return repo.findById(id);
    }

    Page[] list() {
        return repo.findAll();
    }

    Page[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Page[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(PageDTO dto) {
        Page e;
        e.id = PageId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = ApplicationId(dto.applicationId);
        e.name = dto.name;
        e.description = dto.description;
        e.route = dto.route;
        e.layoutConfig = dto.layoutConfig;
        e.componentTree = dto.componentTree;
        e.styleOverrides = dto.styleOverrides;
        e.pageVariables = dto.pageVariables;
        e.sortOrder = dto.sortOrder;
        e.isStartPage = dto.isStartPage;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidPage(e))
            return CommandResult(false, "", "Invalid page data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(PageDTO dto) {
        if (!repo.existsById(PageId(dto.id)))
            return CommandResult(false, "", "Page not found");
        auto existing = repo.findById(PageId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.route.length > 0) existing.route = dto.route;
        if (dto.layoutConfig.length > 0) existing.layoutConfig = dto.layoutConfig;
        if (dto.componentTree.length > 0) existing.componentTree = dto.componentTree;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(PageId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Page not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
