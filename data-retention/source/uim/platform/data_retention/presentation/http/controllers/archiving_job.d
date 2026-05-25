module uim.platform.data_retention.presentation.http.controllers.archiving_job;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ArchivingJobController : PlatformController {
    private ManageArchivingJobsUseCase usecase;

    this(ManageArchivingJobsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/archiving-jobs", &handleCreate);
        router.get("/api/v1/data-retention/archiving-jobs", &handleList);
        router.get("/api/v1/data-retention/archiving-jobs/*", &handleGet);
        router.put("/api/v1/data-retention/archiving-jobs/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/archiving-jobs/*", &handleDelete);
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateArchivingJobRequest r;
            r.tenantId = tenantId;
            r.applicationGroupId = ApplicationGroupId(j.getString("applicationGroupId"));
            r.operationType = j.getString("operationType");
            r.selectionCriteria = j.getString("selectionCriteria");
            r.scheduledAt = jsonLong(j, "scheduledAt");
            r.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createArchivingJob(r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Archiving job created");

                res.writeJsonBody(response, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listArchivingJobs(tenantId);
            auto jarr = Json.emptyArray;
            foreach (aj; items) {
                jarr ~= Json.emptyObject
                    .set("id", aj.id.value)
                    .set("applicationGroupId", aj.applicationGroupId.value)
                    .set("operationType", aj.operationType.to!string)
                    .set("status", aj.status.to!string)
                    .set("recordsProcessed", aj.recordsProcessed);
            }

            auto response = Json.emptyObject
                .set("items", jarr)
                .set("totalCount", items.length)
                .set("message", "Archiving jobs retrieved");

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ArchivingJobId(extractIdFromPath(req.requestURI.to!string));

            auto aj = usecase.getArchivingJob(tenantId, id);
            if (aj.isNull) {
                writeError(res, 404, "Archiving job not found");
                return;
            }
            auto response = Json.emptyObject
                    .set("id", aj.id.value)
                    .set("applicationGroupId", aj.applicationGroupId.value)
                    .set("operationType", aj.operationType.to!string)
                    .set("status", aj.status.to!string)
                    .set("selectionCriteria", aj.selectionCriteria)
                    .set("recordsProcessed", aj.recordsProcessed)
                    .set("recordsFailed", aj.recordsFailed)
                    .set("scheduledAt", aj.scheduledAt);

            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ArchivingJobId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateArchivingJobRequest r;
            r.tenantId = tenantId;
            r.archivingJobId = id;
            r.operationType = j.getString("operationType").to!OperationType;
            r.status = j.getString("status");
            r.recordsProcessed = jsonInt(j, "recordsProcessed");
            r.recordsFailed = jsonInt(j, "recordsFailed");
            r.errorMessage = j.getString("errorMessage");

            auto result = usecase.updateArchivingJob(id, r);
            if (result.success) {
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Archiving job updated");

                res.writeJsonBody(response, 200);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ArchivingJobId(extractIdFromPath(req.requestURI.to!string));

            usecase.deleteArchivingJob(tenantId, id);
            auto response = Json.emptyObject
                .set("id", id)
                .set("message", "Archiving job deleted");

            res.writeJsonBody(response, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
