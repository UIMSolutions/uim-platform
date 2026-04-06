/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.recipe_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface RecipeRepository {
    Recipe[] findAll();
    Recipe* findById(RecipeId id);
    Recipe[] findByTenant(TenantId tenantId);
    Recipe[] findByProduct(string productId);
    Recipe[] findByType(RecipeType recipeType);
    Recipe[] findByStatus(RecipeStatus status);
    void save(Recipe recipe);
    void update(Recipe recipe);
    void remove(RecipeId id);
}
