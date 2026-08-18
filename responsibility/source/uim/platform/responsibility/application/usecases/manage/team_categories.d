/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.team_categories;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ManageTeamCategoriesUseCase {
    private ITeamCategoryRepository repo;

    this(ITeamCategoryRepository repo) { this.repo = repo; }

    TeamCategory getCategory(TenantId tenantId, TeamCategoryId id) {
        return repo.findById(tenantId, id);
    }

    TeamCategory[] listCategories(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult createCategory(TeamCategoryDTO dto) {
        auto c = TeamCategory(dto.tenantId); //, dto.createdBy);
        c.id          = dto.categoryId;
        c.name        = dto.name;
        c.description = dto.description;
        c.code        = dto.code;
        if (c.name.isEmpty)
            return UsecaseResult(false, "", "Category name is required");
        repo.save(c);
        return UsecaseResult(true, c.id.value, "");
    }

    UsecaseResult updateCategory(TeamCategoryDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.categoryId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Category not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.code.length > 0)        existing.code        = dto.code;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteCategory(TenantId tenantId, TeamCategoryId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return UsecaseResult(false, "", "Category not found");
        repo.remove(e);
        return UsecaseResult(true, e.id.value, "");
    }
}
