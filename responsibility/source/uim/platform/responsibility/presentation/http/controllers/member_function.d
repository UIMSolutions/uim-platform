/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.member_function;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemberFunctionController : ManageController {
    private ManageMemberFunctionsUseCase _uc;

    this(ManageMemberFunctionsUseCase uc) { _uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get   ("/api/v1/responsibility/functions",    &handleList);
        router.get   ("/api/v1/responsibility/functions/*",  &handleGet);
        router.post  ("/api/v1/responsibility/functions",    &handleCreate);
        router.put   ("/api/v1/responsibility/functions/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/functions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto pre = super.listHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantIf(pre.gString("tenantId"));
        auto items = _uc.listFunctions(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto pre = super.getHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantIf(pre.gString("tenantId"));
        auto id = MemberFunctionId(extractIdFromPath(req.requestURI.to!string));
        auto e = _uc.getFunction(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Function not found").set("statusCode", 404);
        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto pre = super.createHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantIf(pre.gString("tenantId"));
        auto data = pre["data"];
        import std.uuid : randomUUID;
        MemberFunctionDTO dto;
        dto.functionId  = MemberFunctionId(data.getString("functionId", randomUUID().toString()));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        dto.status      = data.getString("status", "active");
        auto result = _uc.createFunction(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.error).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantIf(pre.gString("tenantId"));
        auto data = pre["data"];
        MemberFunctionDTO dto;
        dto.functionId  = MemberFunctionId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        dto.status      = data.getString("status", "active");
        auto result = _uc.updateFunction(dto);
        if (!result.success)
            return Json.emptyObject.set("error", result.error).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (!pre.success) return Json.emptyObject.set("error", pre.error);
        auto tenantId = TenantIf(pre.gString("tenantId"));
        auto id = MemberFunctionId(extractIdFromPath(req.requestURI.to!string));
        auto result = _uc.deleteFunction(tenantId, id);
        if (!result.success)
            return Json.emptyObject.set("error", result.error).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
