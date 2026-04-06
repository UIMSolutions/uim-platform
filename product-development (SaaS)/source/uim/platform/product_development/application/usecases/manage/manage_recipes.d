/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.application.usecases.manage.manage_recipes;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class ManageRecipesUseCase : UIMUseCase {
    private RecipeRepository repo;

    this(RecipeRepository repo) {
        this.repo = repo;
    }

    Recipe* get_(RecipeId id) {
        return repo.findById(id);
    }

    Recipe[] list() {
        return repo.findAll();
    }

    Recipe[] listByProduct(string productId) {
        return repo.findByProduct(productId);
    }

    CommandResult create(RecipeDTO dto) {
        Recipe r;
        r.id = dto.id;
        r.tenantId = dto.tenantId;
        r.productId = dto.productId;
        r.name = dto.name;
        r.description = dto.description;
        r.version_ = dto.version_;
        r.recipeNumber = dto.recipeNumber;
        r.yield_ = dto.yield_;
        r.yieldUnit = dto.yieldUnit;
        r.batchSize = dto.batchSize;
        r.batchUnit = dto.batchUnit;
        r.shelfLife = dto.shelfLife;
        r.storageConditions = dto.storageConditions;
        r.ingredients = dto.ingredients;
        r.instructions = dto.instructions;
        r.createdBy = dto.createdBy;
        if (!ProductValidator.isValidRecipe(r))
            return CommandResult(false, "", "Invalid recipe data");
        repo.save(r);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(RecipeDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Recipe not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.ingredients.length > 0) existing.ingredients = dto.ingredients;
        if (dto.instructions.length > 0) existing.instructions = dto.instructions;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(RecipeId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Recipe not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
