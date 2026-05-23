/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.http.controllers.service_plan;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class ServicePlanController : ManageController {
    private ManageServicePlansUseCase plans;

    this(ManageServicePlansUseCase plans) { this.plans = plans; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/postgres/plans",        &handleList);
        router.get("/api/v1/postgres/plans/*",      &handleGet);
        router.post("/api/v1/postgres/plans",       &handleCreate);
        router.put("/api/v1/postgres/plans/*",      &handleUpdate);
        router.delete_("/api/v1/postgres/plans/*",  &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto items = plans.listServicePlans(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Service plans retrieved successfully")
            .set("status", "success").set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = ServicePlanId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull) return Json.emptyObject.set("error", "Invalid ID").set("statusCode", 400);
        auto e = plans.getServicePlan(tenantId, id);
        if (e.isNull) return Json.emptyObject.set("error", "Service plan not found").set("statusCode", 404);
        return e.toJson().set("message", "OK").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;
        ServicePlanDTO dto;
        dto.servicePlanId     = ServicePlanId(data.getString("servicePlanId", ""));
        dto.tenantId          = tenantId;
        dto.name              = data.getString("name", "");
        dto.description       = data.getString("description", "");
        dto.memoryGb          = data.getLong("memoryGb", 4);
        dto.storageGb         = data.getLong("storageGb", 20);
        dto.maxConnections    = data.getLong("maxConnections", 100);
        dto.multiAzSupported  = data.getBool("multiAzSupported", false);
        dto.available         = data.getBool("available", true);
        dto.pricingUnit       = data.getString("pricingUnit", "");
        dto.createdBy         = UserId(data.getString("createdBy", ""));
        auto result = plans.createServicePlan(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Service plan created successfully").set("status", "success").set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;
        ServicePlanDTO dto;
        dto.servicePlanId = ServicePlanId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId      = tenantId;
        dto.description   = data.getString("description", "");
        dto.available     = data.getBool("available", true);
        dto.updatedBy     = UserId(data.getString("updatedBy", ""));
        auto result = plans.updateServicePlan(dto);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 400);
        return Json.emptyObject.set("id", result.id).set("message", "Service plan updated successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) return Json.emptyObject.set("error", precheck.error);
        auto tenantId = getTenantId(precheck);
        auto id = ServicePlanId(extractIdFromPath(req.requestURI.to!string));
        auto result = plans.deleteServicePlan(tenantId, id);
        if (result.hasError) return Json.emptyObject.set("error", result.message).set("statusCode", 404);
        return Json.emptyObject.set("id", result.id).set("message", "Service plan deleted successfully").set("status", "success").set("statusCode", 200);
    }
}
