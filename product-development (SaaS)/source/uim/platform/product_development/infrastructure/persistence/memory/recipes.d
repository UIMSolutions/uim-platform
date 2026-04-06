/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.infrastructure.persistence.memory.recipes;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class MemoryRecipeRepository : RecipeRepository {
    private Recipe[] store;

    Recipe[] findAll() { return store; }

    Recipe* findById(RecipeId id) {
        foreach (ref e; store)
            if (e.id == id) return &e;
        return null;
    }

    Recipe[] findByTenant(TenantId tenantId) {
        Recipe[] result;
        foreach (ref e; store)
            if (e.tenantId == tenantId) result ~= e;
        return result;
    }

    Recipe[] findByProduct(string productId) {
        Recipe[] result;
        foreach (ref e; store)
            if (e.productId == productId) result ~= e;
        return result;
    }

    Recipe[] findByType(RecipeType recipeType) {
        Recipe[] result;
        foreach (ref e; store)
            if (e.recipeType == recipeType) result ~= e;
        return result;
    }

    Recipe[] findByStatus(RecipeStatus status) {
        Recipe[] result;
        foreach (ref e; store)
            if (e.status == status) result ~= e;
        return result;
    }

    void save(Recipe recipe) { store ~= recipe; }

    void update(Recipe recipe) {
        foreach (ref e; store)
            if (e.id == recipe.id) { e = recipe; return; }
    }

    void remove(RecipeId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
