/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.member_function;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class MemberFunctionController : ManageHttpController {
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
        auto precheck = super.listHandler(req);
        if (precheck.hasError) 
            return precheck;

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto items = _uc.listFunctions(tenantId);
        auto responseData = Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);

        return successResponse("Member functions listed successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = MemberFunctionId(precheck.gString("id"));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid function ID").set("statusCode", 400);

        auto e = _uc.getFunction(tenantId, id);
        if (e.isNull)
            return errorResponse("Member function not found", 404);

        auto responseData = Json.emptyObject
            .set("status", "success").set("statusCode", 200)
            .set("resource", e.toJson());
        return successResponse("Member function retrieved successfully", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto data = precheck["data"];
        import std.uuid : randomUUID;
        MemberFunctionDTO dto;
        dto.functionId  = MemberFunctionId(data.getString("functionId", generateId));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        dto.status      = data.getString("status", "active");
        auto result = _uc.createFunction(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        auto responseData = Json.emptyObject
            .set("status", "success").set("statusCode", 201)
            .set("id", result.id);
        return successResponse("Member function created successfully", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) 
            return precheck;

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto data = precheck["data"];
        MemberFunctionDTO dto;
        dto.functionId  = MemberFunctionId(precheck.gString("id"));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.code        = data.getString("code", "");
        dto.status      = data.getString("status", "active");
        auto result = _uc.updateFunction(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Member function updated successfully", 200, Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = MemberFunctionId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid function ID").set("statusCode", 400);

        auto result = _uc.deleteFunction(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);#
        return successResponse("Member function deleted successfully", 200, Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200));
    }
}
