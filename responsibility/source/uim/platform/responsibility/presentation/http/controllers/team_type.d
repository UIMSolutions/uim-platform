/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.team_type;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class TeamTypeController : ManageHttpController {
    private ManageTeamTypesUseCase _uc;

    this(ManageTeamTypesUseCase uc) { _uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/responsibility/team-types",    &handleList);
        router.get   ("/api/v1/responsibility/team-types/*",  &handleGet);
        router.post  ("/api/v1/responsibility/team-types",    &handleCreate);
        router.put   ("/api/v1/responsibility/team-types/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/team-types/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto pre = super.listHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto items = _uc.listTypes(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto pre = super.getHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = TeamTypeId(precheck.id);
        auto e = _uc.getType(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "TeamType not found").set("statusCode", 404);
        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto pre = super.createHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data = pre["data"];
        import std.uuid : randomUUID;
        TeamTypeDTO dto;
        dto.typeId      = TeamTypeId(data.getString("typeId", randomUUID().toString()));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        dto.categoryId  = data.getString("categoryId", "");
        auto result = _uc.createType(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data = pre["data"];
        TeamTypeDTO dto;
        dto.typeId      = TeamTypeId(precheck.id);
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        dto.categoryId  = data.getString("categoryId", "");
        auto result = _uc.updateType(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = TeamTypeId(precheck.id);
        auto result = _uc.deleteType(tenantId, id);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
