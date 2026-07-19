/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.service_instance;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ServiceInstanceController : ManageHttpController {
    private ManageServiceInstancesUseCase instances;

    this(ManageServiceInstancesUseCase instances) {
        this.instances = instances;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/instances",   &handleList);
        router.get("/api/v1/redis/instances/*", &handleGet);
        router.post("/api/v1/redis/instances",  &handleCreate);
        router.put("/api/v1/redis/instances/*", &handleUpdate);
        router.delete_("/api/v1/redis/instances/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = instances.listServiceInstances(tenantId);
        return successResponse("Service instances retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service instance ID", 400);

        auto e = instances.getServiceInstance(tenantId, id);
        if (e.isNull)
            return errorResponse("Service instance not found", 404);

        return successResponse("Service instance retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServiceInstanceDTO dto;
        dto.serviceInstanceId = ServiceInstanceId(data.getString("serviceInstanceId", ""));
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.planId            = ServicePlanId(data.getString("planId", ""));
        dto.region            = data.getString("region", "");
        dto.memoryMb          = data.getLong("memoryMb", 256);
        dto.maxConnections    = data.getLong("maxConnections", 100);
        dto.tlsEnabled        = data.getBoolean("tlsEnabled", true);
        dto.haEnabled         = data.getBoolean("haEnabled", false);
        dto.createdBy         = UserId(data.getString("createdBy", ""));

        auto result = instances.createServiceInstance(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Service instance created successfully", "Created", 201, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServiceInstanceDTO dto;
        dto.serviceInstanceId = ServiceInstanceId(precheck.id);
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.memoryMb          = data.getLong("memoryMb", 0);
        dto.maxConnections    = data.getLong("maxConnections", 0);
        dto.updatedBy         = UserId(data.getString("updatedBy", ""));

        auto result = instances.updateServiceInstance(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Service instance updated successfully", "Updated", 200, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);

        auto result = instances.deleteServiceInstance(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Service instance deleted successfully", "Deleted", 200, Json.emptyObject
            .set("id", result.id));
    }
}
