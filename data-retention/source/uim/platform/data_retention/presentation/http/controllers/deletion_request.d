module uim.platform.data_retention.presentation.http.controllers.deletion_request;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DeletionRequestController : PlatformController {
    private ManageDeletionRequestsUseCase uc;

    this(ManageDeletionRequestsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/deletion-requests", &handleCreate);
        router.get("/api/v1/data-retention/deletion-requests", &handleList);
        router.get("/api/v1/data-retention/deletion-requests/*", &handleGet);
        router.put("/api/v1/data-retention/deletion-requests/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/deletion-requests/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDeletionRequestRequest r;
            r.tenantId = req.getTenantId;
            r.dataSubjectId = j.getString("dataSubjectId");
            r.applicationGroupId = j.getString("applicationGroupId");
            r.actionType = j.getString("actionType");
            r.reason = j.getString("reason");
            r.requestedBy = j.getString("requestedBy");

            auto result = uc.create(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.list(tenantId);
            auto jarr = Json.emptyArray;
            foreach (dr; items) {
                jarr ~= Json.emptyObject
                    .set("id", dr.id.value)
                    .set("dataSubjectId", dr.dataSubjectId.value)
                    .set("applicationGroupId", dr.applicationGroupId.value)
                    .set("actionType", dr.actionType.to!string)
                    .set("status", dr.status.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto dr = uc.getById(id);
            if (dr.id.isEmpty) { writeError(res, 404, "Deletion request not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", dr.id.value)
                .set("dataSubjectId", dr.dataSubjectId.value)
                .set("applicationGroupId", dr.applicationGroupId.value)
                .set("actionType", dr.actionType.to!string)
                .set("status", dr.status.to!string)
                .set("reason", dr.reason)
                .set("requestedBy", dr.requestedBy)
                .set("requestedAt", dr.requestedAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateDeletionRequestRequest r;
            r.status = j.getString("status");
            r.errorMessage = j.getString("errorMessage");

            auto result = uc.update(id, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            uc.remove(id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
