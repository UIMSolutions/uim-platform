module uim.platform.service_manager.presentation.http.controllers.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class OperationController : ManageController {
    private ManageOperationsUseCase usecase;

    this(ManageOperationsUseCase usecase) { this.usecase = usecase; }

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
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = req.getTenantId;
            auto id = Operationprecheck.id);

            auto e = usecase.getOperation(tenantId, (id));
            if (e.isNull) { writeError(res, 404, "Operation not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value)
                .set("resourceId", e.resourceId)
                .set("resourceType", e.resourceType)
                .set("type", e.type.to!string)
                .set("status", e.status.to!string)
                .set("description", e.description)
                .set("errorMessage", e.errorMessage)
                .set("createdAt", e.createdAt), 200);

        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto data = precheck.data;

            CreateOperationRequest r;
            r.tenantId = tenantId;
            r.resourceId = j.getString("resourceId");
            r.resourceType = j.getString("resourceType");
            r.type = j.getString("type");
            r.description = j.getString("description");

            auto result = usecase.createOperation(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = Operationprecheck.id);
            auto data = precheck.data;
            UpdateOperationRequest r;
            r.tenantId = tenantId;
            r.operationId = id;
            r.status = j.getString("status");
            r.errorMessage = j.getString("errorMessage");

            auto result = usecase.updateOperation(r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = Operationprecheck.id);

            auto result = usecase.deleteOperation(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
