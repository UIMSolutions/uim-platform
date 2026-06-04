module uim.platform.service_manager.presentation.http.controllers.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class OperationController : ManageHttpController {
    private ManageOperationsUseCase usecase;

    this(ManageOperationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/service-manager/operations", &handleList);
        router.get("/api/v1/service-manager/operations/*", &handleGet);
        router.post("/api/v1/service-manager/operations", &handleCreate);
        router.put("/api/v1/service-manager/operations/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/operations/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listOperations(tenantId);
        auto jarr = Json.emptyArray;
        foreach (e; items) {
            jarr ~= Json.emptyObject
                .set("id", e.id.value)
                .set("resourceId", e.resourceId)
                .set("resourceType", e.resourceType)
                .set("type", e.type.to!string)
                .set("status", e.status.to!string);
        }
        return successResponse("Operations retrieved successfully", 200, Json.emptyObject.set("items", jarr).set(
                "totalCount", items.length));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = OperationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid operation ID", 400);

        auto e = usecase.getOperation(tenantId, (id));
        if (e.isNull)
            return errorResponse("Operation not found", 404);

        auto responseData = Json.emptyObject
            .set("id", e.id.value)
            .set("resourceId", e.resourceId)
            .set("resourceType", e.resourceType)
            .set("type", e.type.to!string)
            .set("status", e.status.to!string)
            .set("description", e.description)
            .set("errorMessage", e.errorMessage)
            .set("createdAt", e.createdAt);
        return successResponse("Operation retrieved successfully", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateOperationRequest r;
        r.tenantId = precheck.tenantId;
        r.resourceId = data.getString("resourceId");
        r.resourceType = data.getString("resourceType");
        r.type = data.getString("type");
        r.description = data.getString("description");

        auto result = usecase.createOperation(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Operation created successfully", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = OperationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid operation ID", 400);

        auto data = precheck.data;
        UpdateOperationRequest r;
        r.tenantId = precheck.tenantId;
        r.operationId = id;
        r.status = data.getString("status");
        r.errorMessage = data.getString("errorMessage");

        auto result = usecase.updateOperation(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Operation updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = OperationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid operation ID", 400);

        auto result = usecase.deleteOperation(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Operation deleted successfully", 200, responseData);
    }
}
