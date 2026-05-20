module uim.platform.data_retention.presentation.http.controllers.deletion_request;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DeletionRequestController : PlatformController {
    private ManageDeletionRequestsUseCase usecase;

    this(ManageDeletionRequestsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/deletion-requests", &handleCreate);
        router.get("/api/v1/data-retention/deletion-requests", &handleList);
        router.get("/api/v1/data-retention/deletion-requests/*", &handleGet);
        router.put("/api/v1/data-retention/deletion-requests/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/deletion-requests/*", &handleDelete);
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateDeletionRequestRequest r;
            r.tenantId = tenantId;
            r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
            r.applicationGroupId = ApplicationGroupId(j.getString("applicationGroupId"));
            r.actionType = j.getString("actionType").to!ActionType;
            r.reason = j.getString("reason");
            r.requestedBy = j.getString("requestedBy");

            auto result = usecase.createDeletionRequest(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listDeletionRequests(tenantId);
            auto jarr = Json.emptyArray;
            foreach (dr; items) {
                jarr ~= Json.emptyObject
                    .set("id", dr.id.value)
                    .set("dataSubjectId", dr.dataSubjectId.value)
                    .set("applicationGroupId", dr.applicationGroupId.value)
                    .set("actionType", dr.actionType.to!string)
                    .set("status", dr.status.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr)
                    .set("totalCount", items.length), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DeletionRequestId(extractIdFromPath(req.requestURI.to!string));
            auto dr = usecase.getDeletionRequest(tenantId, id);
            if (dr.isNull) {
                writeError(res, 404, "Deletion request not found");
                return;
            }

            auto response = Json.emptyObject
                    .set("id", dr.id.value)
                    .set("dataSubjectId", dr.dataSubjectId.value)
                    .set("applicationGroupId", dr.applicationGroupId.value)
                    .set("actionType", dr.actionType.to!string)
                    .set("status", dr.status.to!string)
                    .set("reason", dr.reason)
                    .set("requestedBy", dr.requestedBy)
                    .set("requestedAt", dr.requestedAt);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
                    .set("reason", dr.reason)
                    .set("requestedBy", dr.requestedBy)
                    .set("requestedAt", dr.requestedAt), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DeletionRequestId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateDeletionRequestRequest r;
            r.tenantId = tenantId;
            r.dataSubjectId = DataSubjectId(j.getString("dataSubjectId"));
            r.status = j.getString("status");
            r.errorMessage = j.getString("errorMessage");

            auto result = usecase.updateDeletionRequest(id, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = DeletionRequestId(extractIdFromPath(req.requestURI.to!string));

            auto result = usecase.deleteDeletionRequest(tenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
