/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.team_member;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class TeamMemberController : ManageHttpController {
    private ManageTeamMembersUseCase usecase;

    this(ManageTeamMembersUseCase uc) { usecase = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/responsibility/team-members",    &handleList);
        router.get   ("/api/v1/responsibility/team-members/*",  &handleGet);
        router.post  ("/api/v1/responsibility/team-members",    &handleCreate);
        router.put   ("/api/v1/responsibility/team-members/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/team-members/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = precheck.tenantId;
        auto items = usecase.listMembers(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = precheck.tenantId;
        auto id = TeamMemberId(precheck.id);
        auto e = usecase.getMember(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Member not found").set("statusCode", 404);
        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto pre = super.createHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        import std.uuid : randomUUID;
        TeamMemberDTO dto;
        dto.memberId     = TeamMemberId(data.getString("memberId", generateId));
        dto.tenantId     = tenantId;
        dto.teamId       = data.getString("teamId", "");
        dto.userId       = data.getString("userId", "");
        dto.email        = data.getString("email", "");
        dto.displayName  = data.getString("displayName", "");
        dto.functionId   = data.getString("functionId", "");
        dto.role         = data.getString("role", "responsible");
        dto.validFrom    = data.getString("validFrom", "");
        dto.validTo      = data.getString("validTo", "");
        auto result = usecase.addMember(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        TeamMemberDTO dto;
        dto.memberId    = TeamMemberId(precheck.id);
        dto.tenantId    = tenantId;
        dto.role        = data.getString("role", "responsible");
        dto.validFrom   = data.getString("validFrom", "");
        dto.validTo     = data.getString("validTo", "");
        auto result = usecase.updateMember(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = precheck.tenantId;
        auto id = TeamMemberId(precheck.id);
        auto result = usecase.removeMember(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
