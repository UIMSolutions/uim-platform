/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.presentation.http.controllers.recipe;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

class RecipeController : SAPController {
    private ManageRecipesUseCase uc;

    this(ManageRecipesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/product-development/recipes", &handleList);
        router.get("/api/v1/product-development/recipes/*", &handleGet);
        router.post("/api/v1/product-development/recipes", &handleCreate);
        router.put("/api/v1/product-development/recipes/*", &handleUpdate);
        router.delete_("/api/v1/product-development/recipes/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref e; items) jarr ~= recipeToJson(e);
            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) items.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.get_(id);
            if (e is null) { writeError(res, 404, "Recipe not found"); return; }
            res.writeJsonBody(recipeToJson(*e), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            RecipeDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.productId = jsonStr(j, "productId");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.recipeType = jsonStr(j, "recipeType");
            dto.version_ = jsonStr(j, "version");
            dto.recipeNumber = jsonStr(j, "recipeNumber");
            dto.yield_ = jsonStr(j, "yield");
            dto.yieldUnit = jsonStr(j, "yieldUnit");
            dto.batchSize = jsonStr(j, "batchSize");
            dto.batchUnit = jsonStr(j, "batchUnit");
            dto.shelfLife = jsonStr(j, "shelfLife");
            dto.storageConditions = jsonStr(j, "storageConditions");
            dto.ingredients = jsonStr(j, "ingredients");
            dto.instructions = jsonStr(j, "instructions");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Recipe created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            RecipeDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.version_ = jsonStr(j, "version");
            dto.yield_ = jsonStr(j, "yield");
            dto.ingredients = jsonStr(j, "ingredients");
            dto.instructions = jsonStr(j, "instructions");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Recipe updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Recipe deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
