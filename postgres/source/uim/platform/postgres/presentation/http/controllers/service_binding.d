/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.service_binding;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class ServiceBindingController : ManageHttpController {
    private ManageServiceBindingsUseCase bindings;

    this(ManageServiceBindingsUseCase bindings) {
        this.bindings = bindings;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/postgres/bindings", &handleList);
        router.get("/api/v1/postgres/bindings/*", &handleGet);
        router.post("/api/v1/postgres/bindings", &handleCreate);
        router.delete_("/api/v1/postgres/bindings/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto items = bindings.listServiceBindings(tenantId);
        return successResponse("Service bindings retrieved successfully", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto id = ServiceBindingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid ID", 400, Json.emptyObject.set("error", "Invalid ID"));
        auto e = bindings.getServiceBinding(tenantId, id);
        if (e.isNull)
            return errorResponse("Service binding not found", 404, Json.emptyObject.set("error", "Service binding not found"));
        return successResponse("Service binding retrieved successfully", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServiceBindingDTO dto;
        dto.serviceBindingId = ServiceBindingId(data.getString("serviceBindingId", ""));
        dto.tenantId = tenantId;
        dto.instanceId = ServiceInstanceId(data.getString("instanceId", ""));
        dto.appId = data.getString("appId", "");
        dto.name = data.getString("name", "");
        dto.expiresAt = data.getLong("expiresAt", 0);
        dto.createdBy = UserId(data.getString("createdBy", ""));
        auto result = bindings.createServiceBinding(dto);
        if (result.hasError)
            return errorResponse("Service binding creation failed", 400, Json.emptyObject.set("error", result.message));
        return successResponse("Service binding created successfully", 201, Json.emptyObject.set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;
        auto tenantId = precheck.tenantId;
        auto id = ServiceBindingId(precheck.id);
        auto result = bindings.deleteServiceBinding(tenantId, id);
        if (result.hasError)
            return errorResponse("Service binding deletion failed", 404, Json.emptyObject.set("error", result.message));
        return successResponse("Service binding deleted successfully", 200, Json.emptyObject.set("id", result.id));
    }
}
