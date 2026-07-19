module uim.platform.data_retention.presentation.http.controllers.archiving_job;
import uim.platform.data_retention;
mixin(ShowModule!());

@safe:

class ArchivingJobController : ManageHttpController {
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateArchivingJobRequest r;
        r.tenantId = tenantId;
        r.applicationGroupId = ApplicationGroupId(data.getString("applicationGroupId"));
        r.operationType = data.getString("operationType");
        r.selectionCriteria = data.getString("selectionCriteria");
        r.scheduledAt = data.getLong("scheduledAt");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createArchivingJob(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Archiving job created successfully", 201, responseData);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

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

        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);
        return successResponse("Archiving jobs retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ArchivingJobId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid archiving job ID", 400);

        auto aj = usecase.getArchivingJob(tenantId, id);
        if (aj.isNull)
            return errorResponse("Data subject not found", 404);

        auto responseData = Json.emptyObject
            .set("id", aj.id.value)
            .set("applicationGroupId", aj.applicationGroupId.value)
            .set("operationType", aj.operationType.to!string)
            .set("status", aj.status.to!string)
            .set("selectionCriteria", aj.selectionCriteria)
            .set("recordsProcessed", aj.recordsProcessed)
            .set("recordsFailed", aj.recordsFailed)
            .set("scheduledAt", aj.scheduledAt);

        return successResponse("Archiving job retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ArchivingJobId(precheck.id);
        auto data = precheck.data;
        UpdateArchivingJobRequest r;
        r.tenantId = tenantId;
        r.archivingJobId = id;
        r.operationType = data.getString("operationType").to!OperationType;
        r.status = data.getString("status");
        r.recordsProcessed = jsonInt(j, "recordsProcessed");
        r.recordsFailed = jsonInt(j, "recordsFailed");
        r.errorMessage = data.getString("errorMessage");

        auto result = usecase.updateArchivingJob(id, r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Archiving job updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ArchivingJobId(precheck.id);

        auto result = usecase.deleteArchivingJob(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Archiving job deleted successfully", 200, responseData);
    }
}
