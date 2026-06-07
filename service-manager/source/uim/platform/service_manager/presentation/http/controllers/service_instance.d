module uim.platform.service_manager.presentation.http.controllers.service_instance;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

class ServiceInstanceController : ManageHttpController {
    private ManageServiceInstancesUseCase usecase;

    this(ManageServiceInstancesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/service-instances", &handleList);
        router.get("/api/v1/service-manager/service-instances/*", &handleGet);
        router.post("/api/v1/service-manager/service-instances", &handleCreate);
        router.put("/api/v1/service-manager/service-instances/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-instances/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listInstances(tenantId);
        auto list = Json.emptyArray;
        foreach (e; items) {
            list ~= Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("planId", e.planId.value)
                .set("status", e.status.to!string)
                .set("shared", e.shared_)
                .set("usable", e.usable);
        }

        auto responseData = Json.emptyObject
            .set("items", list)
            .set("totalCount", Json(items.length));
        return successResponse("Service instances retrieved successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service instance ID", 400);

        auto e = usecase.getInstance(tenantId, id);
        if (e.isNull)
            return errorResponse("Service instance not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value).set("name", e.name)
            .set("planId", e.planId.value)
            .set("offeringId", e.offeringId.value)
            .set("platformId", e.platformId.value)
            .set("status", e.status.to!string)
            .set("shared", e.shared_)
            .set("usable", e.usable)
            .set("dashboardUrl", e.dashboardUrl)
            .set("createdAt", e.createdAt);

        return successResponse("Service instance retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateServiceInstanceRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.planId = data.getString("planId");
        r.offeringId = data.getString("offeringId");
        r.platformId = data.getString("platformId");
        r.context = data.getString("context");
        r.parameters = data.getString("parameters");
        r.labels = data.getString("labels");

        auto result = usecase.createInstance(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service instance created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service instance ID", 400);

        auto data = precheck.data;
        UpdateServiceInstanceRequest r;
        r.tenantId = tenantId;
        r.instanceId = id;
        r.name = data.getString("name");
        r.planId = data.getString("planId");
        r.parameters = data.getString("parameters");
        r.labels = data.getString("labels");

        auto result = usecase.updateInstance(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service instance updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ServiceInstanceId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service instance ID", 400);

        auto result = usecase.deleteInstance(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service instance deleted successfully", "Deleted", 200, responseData);
    }
}
