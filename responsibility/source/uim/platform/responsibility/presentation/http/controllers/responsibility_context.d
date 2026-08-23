/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.presentation.http.controllers.responsibility_context;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ResponsibilityContextController : ManageHttpController {
    private ManageResponsibilityContextsUseCase usecase;

    this(ManageResponsibilityContextsUseCase uc) { usecase = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get   ("/api/v1/responsibility/contexts",    &handleList);
        router.get   ("/api/v1/responsibility/contexts/*",  &handleGet);
        router.post  ("/api/v1/responsibility/contexts",    &handleCreate);
        router.put   ("/api/v1/responsibility/contexts/*",  &handleUpdate);
        router.delete_("/api/v1/responsibility/contexts/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(pre.getString("tenantId"));
        auto items = usecase.listContexts(tenantId);
        return Json.emptyObject
            .set("count",     items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("status",    "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(precheck.getString("tenantId"));
        auto id = ResponsibilityContextId(precheck.id);
        if (id.isNull)
            return error("Invalid context ID", 400);

        auto e = usecase.getContext(tenantId, id);
        if (e.isNull)
            return error("Context not found", 404); 

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) 
            return precheck;

        auto tenantId = TenantId(precheck.getString("tenantId"));
        auto data = precheck["data"];
        import std.uuid : randomUUID;
        ResponsibilityContextDTO dto;
        dto.contextId   = ResponsibilityContextId(data.getString("contextId", generateId));
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.objectType  = data.getString("objectType", "");
        dto.namespace_  = data.getString("namespace", "");
        dto.status      = data.getString("status", "active");
        auto result = usecase.createContext(dto);
        if (result.hasError)
            return error(result.message, 400);

        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto pre = super.updateHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(pre.getString("tenantId"));
        auto data = pre["data"];
        ResponsibilityContextDTO dto;
        dto.contextId   = ResponsibilityContextId(precheck.id);
        dto.tenantId    = tenantId;
        dto.name        = data.getString("name", "");
        dto.description = data.getString("description", "");
        dto.status      = data.getString("status", "active");
        auto result = usecase.updateContext(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto pre = super.deleteHandler(req);
        if (precheck.hasError) 
            return precheck;
        auto tenantId = TenantId(pre.getString("tenantId"));
        auto id = ResponsibilityContextId(precheck.id);
        auto result = usecase.deleteContext(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("status", "success").set("statusCode", 200);
    }
}
