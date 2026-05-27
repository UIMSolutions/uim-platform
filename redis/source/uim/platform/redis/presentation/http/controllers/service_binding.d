/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.service_binding;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ServiceBindingController : ManageController {
    private ManageServiceBindingsUseCase bindings;

    this(ManageServiceBindingsUseCase bindings) {
        this.bindings = bindings;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/bindings",   &handleList);
        router.get("/api/v1/redis/bindings/*", &handleGet);
        router.post("/api/v1/redis/bindings",  &handleCreate);
        router.delete_("/api/v1/redis/bindings/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = bindings.listServiceBindings(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Service bindings retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = ServiceBindingprecheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid service binding ID").set("statusCode", 400);

        auto e = bindings.getServiceBinding(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Service binding not found").set("statusCode", 404);

        return e.toJson().set("message", "Service binding retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServiceBindingDTO dto;
        dto.serviceBindingId = ServiceBindingId(data.getString("serviceBindingId", ""));
        dto.tenantId         = tenantId;
        dto.instanceId       = ServiceInstanceId(data.getString("instanceId", ""));
        dto.appId            = data.getString("appId", "");
        dto.name             = data.getString("name", "");
        dto.expiresAt        = data.getLong("expiresAt", 0);
        dto.createdBy        = UserId(data.getString("createdBy", ""));

        auto result = bindings.createServiceBinding(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Service binding created successfully")
            .set("status", "success")
            .set("statusCode", 201);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = ServiceBindingprecheck.id);

        auto result = bindings.deleteServiceBinding(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Service binding deleted successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
