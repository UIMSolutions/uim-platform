module uim.platform.data_retention.presentation.http.controllers.archiving_job;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ArchivingJobController : PlatformController {
    private ManageArchivingJobsUseCase uc;

    this(ManageArchivingJobsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/archiving-jobs", &handleCreate);
        router.get("/api/v1/data-retention/archiving-jobs", &handleList);
        router.get("/api/v1/data-retention/archiving-jobs/*", &handleGet);
        router.put("/api/v1/data-retention/archiving-jobs/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/archiving-jobs/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateArchivingJobRequest r;
            r.tenantId = req.getTenantId;
            r.applicationGroupId = j.getString("applicationGroupId");
            r.operationType = j.getString("operationType");
            r.selectionCriteria = j.getString("selectionCriteria");
            r.scheduledAt = jsonLong(j, "scheduledAt");
            r.createdBy = j.getString("createdBy");

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
            foreach (aj; items) {
                jarr ~= Json.emptyObject
                    .set("id", aj.id.value)
                    .set("applicationGroupId", aj.applicationGroupId.value)
                    .set("operationType", aj.operationType.to!string)
                    .set("status", aj.status.to!string)
                    .set("recordsProcessed", aj.recordsProcessed);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto aj = uc.getById(id);
            if (aj.id.isEmpty) { writeError(res, 404, "Archiving job not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", aj.id.value)
                .set("applicationGroupId", aj.applicationGroupId.value)
                .set("operationType", aj.operationType.to!string)
                .set("status", aj.status.to!string)
                .set("selectionCriteria", aj.selectionCriteria)
                .set("recordsProcessed", aj.recordsProcessed)
                .set("recordsFailed", aj.recordsFailed)
                .set("scheduledAt", aj.scheduledAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateArchivingJobRequest r;
            r.status = j.getString("status");
            r.recordsProcessed = jsonInt(j, "recordsProcessed");
            r.recordsFailed = jsonInt(j, "recordsFailed");
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
