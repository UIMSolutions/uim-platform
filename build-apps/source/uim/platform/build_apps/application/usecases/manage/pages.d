/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.pages;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManagePagesUseCase { // TODO: UIMUseCase {
    private PageRepository repo;

    this(PageRepository repo) {
        this.repo = repo;
    }

    Page getPage(TenantId tenantId, PageId id) {
        return repo.findById(tenantId, id);
    }

    Page[] listPages(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Page[] listPages(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createPage(PageDTO dto) {
        auto e = Page(dto.tenantId, dto.pageId.isNull ? PageId(createId()) : dto.pageId, dto.createdBy);
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        e.route = dto.route;
        e.layoutConfig = dto.layoutConfig;
        e.componentTree = dto.componentTree;
        e.styleOverrides = dto.styleOverrides;
        e.pageVariables = dto.pageVariables;
        e.sortOrder = dto.sortOrder;
        e.isStartPage = dto.isStartPage;
        if (!BuildAppsValidator.isValidPage(e))
            return CommandResult(false, "", "Invalid page data");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updatePage(PageDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.pageId);
        if (existing.isNull )
            return CommandResult(false, "", "Page not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.route.length > 0) existing.route = dto.route;
        if (dto.layoutConfig.length > 0) existing.layoutConfig = dto.layoutConfig;
        if (dto.componentTree.length > 0) existing.componentTree = dto.componentTree;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePage(TenantId tenantId, PageId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Page not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
