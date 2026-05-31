/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.service_instance;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class ServiceInstanceController : ManageController {
    private ManageServiceInstancesUseCase instances;

    this(ManageServiceInstancesUseCase instances) { this.instances = instances; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/postgres/instances",        &handleList);
        router.get("/api/v1/postgres/instances/*",      &handleGet);
        router.post("/api/v1/postgres/instances",       &handleCreate);
        router.put("/api/v1/postgres/instances/*",      &handleUpdate);
        router.delete_("/api/v1/postgres/instances/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto items = instances.listServiceInstances(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Service instances retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = instances.getServiceInstance(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Service instance not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServiceInstanceDTO dto;
        dto.serviceInstanceId = ServiceInstanceId(data.getString("serviceInstanceId", ""));
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.planId            = ServicePlanId(data.getString("planId", ""));
        dto.region            = data.getString("region", "");
        dto.memoryGb          = data.getLong("memoryGb", 4);
        dto.storageGb         = data.getLong("storageGb", 20);
        dto.sslEnabled        = data.getBoolean("sslEnabled", true);
        dto.multiAz           = data.getBoolean("multiAz", false);
        dto.createdBy         = UserId(data.getString("createdBy", ""));
        auto result = instances.createServiceInstance(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Service instance created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServiceInstanceDTO dto;
        dto.serviceInstanceId = ServiceInstanceId(precheck.id);
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.memoryGb          = data.getLong("memoryGb", 0);
        dto.storageGb         = data.getLong("storageGb", 0);
        dto.updatedBy         = UserId(data.getString("updatedBy", ""));
        auto result = instances.updateServiceInstance(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Service instance updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return precheck;
        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        auto result = instances.deleteServiceInstance(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Service instance deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
