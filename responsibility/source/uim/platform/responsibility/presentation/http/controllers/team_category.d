/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.team_category;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class TeamCategoryController : ManageHttpController {
    private ManageTeamCategoriesUseCase _uc;

    this(ManageTeamCategoriesUseCase uc) { _uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/responsibility/team-categories",    &handleList);
        router.get   ("/api/v1/responsibility/team-categories/*",  &handleGet);
        router.post  ("/api/v1/responsibility/team-categories",    &handleCreate);
        router.put   ("/api/v1/responsibility/team-categories/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/team-categories/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto pre = super.listHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto items = _uc.listCategories(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto pre = super.getHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = TeamCategoryId(precheck.id);
        auto e = _uc.getCategory(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Category not found").set("statusCode", 404);
        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto pre = super.createHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data = pre["data"];
        import std.uuid : randomUUID;
        TeamCategoryDTO dto;
        dto.categoryId  = TeamCategoryId(data.getString("categoryId", randomUUID().toString()));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        auto result = _uc.createCategory(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data = pre["data"];
        TeamCategoryDTO dto;
        dto.categoryId  = TeamCategoryId(precheck.id);
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        auto result = _uc.updateCategory(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = TeamCategoryId(precheck.id);
        auto result = _uc.deleteCategory(tenantId, id);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
