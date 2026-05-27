/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.service_plan;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ServicePlanController : ManageController {
    private ManageServicePlansUseCase plans;

    this(ManageServicePlansUseCase plans) {
        this.plans = plans;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/plans",   &handleList);
        router.get("/api/v1/redis/plans/*", &handleGet);
        router.post("/api/v1/redis/plans",  &handleCreate);
        router.put("/api/v1/redis/plans/*", &handleUpdate);
        router.delete_("/api/v1/redis/plans/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = plans.listServicePlans(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Service plans retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = ServicePlanprecheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid service plan ID").set("statusCode", 400);

        auto e = plans.getServicePlan(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Service plan not found").set("statusCode", 404);

        return e.toJson().set("message", "Service plan retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServicePlanDTO dto;
        dto.servicePlanId       = ServicePlanId(data.getString("servicePlanId", ""));
        dto.tenantId            = tenantId;
        dto.name                = data.getString("name", "");
        dto.description         = data.getString("description", "");
        dto.memoryMb            = data.getLong("memoryMb", 256);
        dto.maxConnections      = data.getLong("maxConnections", 100);
        dto.haEnabled           = data.getBoolean("haEnabled", false);
        dto.persistenceEnabled  = data.getBoolean("persistenceEnabled", false);
        dto.tlsEnabled          = data.getBoolean("tlsEnabled", true);
        dto.pricingUnit         = data.getString("pricingUnit", "");
        dto.available           = data.getBoolean("available", true);
        dto.createdBy           = UserId(data.getString("createdBy", ""));

        auto result = plans.createServicePlan(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Service plan created successfully")
            .set("status", "success")
            .set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ServicePlanDTO dto;
        dto.servicePlanId  = ServicePlanprecheck.id);
        dto.tenantId       = tenantId;
        dto.name           = data.getString("name", "");
        dto.description    = data.getString("description", "");
        dto.memoryMb       = data.getLong("memoryMb", 0);
        dto.pricingUnit    = data.getString("pricingUnit", "");
        dto.updatedBy      = UserId(data.getString("updatedBy", ""));

        auto result = plans.updateServicePlan(dto);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Service plan updated successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto id = ServicePlanprecheck.id);

        auto result = plans.deleteServicePlan(tenantId, id);
        if (result.hasError)
            return Json.emptyObject.set("error", result.message).set("statusCode", 404);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Service plan deleted successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
