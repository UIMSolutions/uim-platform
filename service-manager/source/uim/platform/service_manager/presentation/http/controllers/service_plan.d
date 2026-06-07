module uim.platform.service_manager.presentation.http.controllers.service_plan;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

class ServicePlanController : ManageHttpController {
    private ManageServicePlansUseCase usecase;

    this(ManageServicePlansUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/service-plans", &handleList);
        router.get("/api/v1/service-manager/service-plans/*", &handleGet);
        router.post("/api/v1/service-manager/service-plans", &handleCreate);
        router.put("/api/v1/service-manager/service-plans/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-plans/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listPlans(tenantId);
        auto list = Json.emptyArray;
        foreach (e; items) {
            list ~= Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("offeringId", e.offeringId.value)
                .set("pricing", e.pricing.to!string)
                .set("free", e.free);
        }
        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Service plans retrieved successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServicePlanId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service plan ID", 400);

        auto e = usecase.getPlan(tenantId, id);
        if (e.isNull)
            return errorResponse("Service plan not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value).set("name", e.name)
            .set("description", e.description)
            .set("offeringId", e.offeringId.value)
            .set("pricing", e.pricing.to!string)
            .set("free", e.free)
            .set("bindable", e.bindable)
            .set("maxInstances", e.maxInstances)
            .set("createdAt", e.createdAt);

        return successResponse("Service plan retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateServicePlanRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.catalogName = data.getString("catalogName");
        r.offeringId = data.getString("offeringId");
        r.pricing = data.getString("pricing");
        r.schemas = data.getString("schemas");
        r.metadata = data.getString("metadata");

        auto result = usecase.createPlan(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service plan created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServicePlanId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service plan ID", 400);

        auto data = precheck.data;
        UpdateServicePlanRequest r;
        r.tenantId = tenantId;
        r.planId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.schemas = data.getString("schemas");
        r.metadata = data.getString("metadata");

        auto result = usecase.updatePlan(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service plan updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServicePlanId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service plan ID", 400);

        auto result = usecase.deletePlan(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service plan deleted successfully", "Deleted", 200, responseData);
    }
}
