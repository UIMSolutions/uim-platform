module uim.platform.service_manager.presentation.http.controllers.operation;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class OperationController : PlatformController {
    private ManageOperationsUseCase uc;

    this(ManageOperationsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/operations", &handleList);
        router.get("/api/v1/service-manager/operations/*", &handleGet);
        router.post("/api/v1/service-manager/operations", &handleCreate);
        router.put("/api/v1/service-manager/operations/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/operations/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.listByTenant(tenantId);
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

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, OperationId(id));
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateOperationRequest r;
            r.resourceId = j.getString("resourceId");
            r.resourceType = j.getString("resourceType");
            r.type = j.getString("type");
            r.description = j.getString("description");

            auto result = uc.create(req.getTenantId, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateOperationRequest r;
            r.status = j.getString("status");
            r.errorMessage = j.getString("errorMessage");

            auto result = uc.update(req.getTenantId, OperationId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, OperationId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
