module uim.platform.service_manager.presentation.http.controllers.service_binding;

import uim.platform.service_manager;
mixin(ShowModule!());

@safe:

class ServiceBindingController : ManageHttpController {
    private ManageServiceBindingsUseCase usecase;

    this(ManageServiceBindingsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/service-bindings", &handleList);
        router.get("/api/v1/service-manager/service-bindings/*", &handleGet);
        router.post("/api/v1/service-manager/service-bindings", &handleCreate);
        router.put("/api/v1/service-manager/service-bindings/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-bindings/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listBindings(tenantId);
        auto list = Json.emptyArray;
        foreach (e; items) {
            list ~= Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("instanceId", e.instanceId.value)
                .set("status", e.status.to!string);
        }

        auto responseData = Json.emptyObject
            .set("items", list)
            .set("totalCount", items.length);
        return successResponse("Service bindings retrieved successfully", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceBindingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service binding ID", 400);

        auto e = usecase.getBinding(tenantId, id);
        if (e.isNull)
            return errorResponse("Service binding not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value).set("name", e.name)
            .set("instanceId", e.instanceId.value)
            .set("status", e.status.to!string)
            .set("credentials", e.credentials)
            .set("createdAt", e.createdAt);

        return successResponse("Service binding retrieved successfully", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateServiceBindingRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.instanceId = data.getString("instanceId");
        r.parameters = data.getString("parameters");
        r.bindResource = data.getString("bindResource");
        r.context = data.getString("context");
        r.labels = data.getString("labels");

        auto result = usecase.createBinding(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service binding created successfully", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceBindingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service binding ID", 400);

        auto data = precheck.data;
        UpdateServiceBindingRequest r;
        r.tenantId = tenantId;
        r.bindingId = id;
        r.name = data.getString("name");
        r.parameters = data.getString("parameters");
        r.labels = data.getString("labels");

        auto result = usecase.updateBinding(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Service binding updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ServiceBindingId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid service binding ID", 400);

        auto result = usecase.deleteBinding(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("Service binding deleted successfully", 200, responseData);
    }
}
