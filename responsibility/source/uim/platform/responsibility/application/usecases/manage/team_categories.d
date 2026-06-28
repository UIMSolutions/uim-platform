/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.team_categories;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class ManageTeamCategoriesUseCase {
    private TeamCategoryRepository repo;

    this(TeamCategoryRepository repo) { this.repo = repo; }

    TeamCategory getCategory(TenantId tenantId, TeamCategoryId id) {
        return repo.findById(tenantId, id);
    }

    TeamCategory[] listCategories(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult createCategory(TeamCategoryDTO dto) {
        TeamCategory c;
        c.initEntity(dto.tenantId, dto.createdBy);
        c.id          = dto.categoryId;
        c.name        = dto.name;
        c.description = dto.description;
        c.code        = dto.code;
        if (c.name.length == 0)
            return CommandResult(false, "", "Category name is required");
        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    CommandResult updateCategory(TeamCategoryDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.categoryId);
        if (existing.isNull)
            return CommandResult(false, "", "Category not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.code.length > 0)        existing.code        = dto.code;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteCategory(TenantId tenantId, TeamCategoryId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Category not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }
}
