/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.recipe;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct Recipe {
    RecipeId id;
    TenantId tenantId;
    string productId;
    string name;
    string description;
    RecipeType recipeType = RecipeType.master;
    RecipeStatus status = RecipeStatus.draft;
    string version_;
    string recipeNumber;
    string yield_;
    string yieldUnit;
    string batchSize;
    string batchUnit;
    string shelfLife;
    string storageConditions;
    string ingredients;
    string instructions;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
