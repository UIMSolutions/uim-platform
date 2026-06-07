/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.team;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class TeamController : ManageHttpController {
    private ManageTeamsUseCase _uc;

    this(ManageTeamsUseCase uc) { _uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/responsibility/teams",    &handleList);
        router.get   ("/api/v1/responsibility/teams/*",  &handleGet);
        router.post  ("/api/v1/responsibility/teams",    &handleCreate);
        router.put   ("/api/v1/responsibility/teams/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/teams/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto pre = super.listHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto items = _uc.listTeams(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto pre = super.getHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = TeamId(precheck.id);
        auto e = _uc.getTeam(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Team not found").set("statusCode", 404);
        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto pre = super.createHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data = pre["data"];
        import std.uuid : randomUUID;
        TeamDTO dto;
        dto.teamId      = TeamId(data.getString("teamId", randomUUID().toString()));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.teamTypeId  = data.getString("teamTypeId", "");
        dto.categoryId  = data.getString("categoryId", "");
        dto.status      = data.getString("status", "active");
        dto.scope_      = data.getString("scope", "global");
        auto result = _uc.createTeam(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data = pre["data"];
        TeamDTO dto;
        dto.teamId      = TeamId(precheck.id);
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.status      = data.getString("status", "active");
        auto result = _uc.updateTeam(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = TeamId(precheck.id);
        auto result = _uc.deleteTeam(tenantId, id);
        if (!result.success)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
