/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.responsibility_rule;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ResponsibilityRuleController : ManageController {
    private ManageResponsibilityRulesUseCase _uc;

    this(ManageResponsibilityRulesUseCase uc) { _uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/responsibility/rules",    &handleList);
        router.get   ("/api/v1/responsibility/rules/*",  &handleGet);
        router.post  ("/api/v1/responsibility/rules",    &handleCreate);
        router.put   ("/api/v1/responsibility/rules/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/rules/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto pre = super.listHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto items = _uc.listRules(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto pre = super.getHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = ResponsibilityRuleId(extractIdFromPath(req.requestURI.to!string));
        auto e = _uc.getRule(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Rule not found").set("statusCode", 404);
        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto pre = super.createHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data     = pre["data"];

        import std.uuid : randomUUID;
        auto id = ResponsibilityRuleId(data.getString("ruleId", randomUUID().toString()));
        ResponsibilityRuleDTO dto;
        dto.ruleId      = id;
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.ruleType    = data.getString("ruleType", "directAssignment");
        dto.status      = data.getString("status", "active");
        dto.expression  = data.getString("expression", "");
        dto.priority    = data.getString("priority", "10");
        dto.contextId   = data.getString("contextId", "");
        dto.teamId      = data.getString("teamId", "");

        auto result = _uc.createRule(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto data     = pre["data"];
        auto id = ResponsibilityRuleId(extractIdFromPath(req.requestURI.to!string));

        ResponsibilityRuleDTO dto;
        dto.ruleId      = id;
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.expression  = data.getString("expression", "");
        dto.teamId      = data.getString("teamId", "");

        auto result = _uc.updateRule(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantId(pre.gString("tenantId"));
        auto id = ResponsibilityRuleId(extractIdFromPath(req.requestURI.to!string));

        auto result = _uc.deleteRule(tenantId, id);
        if (!result.success)
            return Json.emptyObject.set("error", result.errorMessage).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
