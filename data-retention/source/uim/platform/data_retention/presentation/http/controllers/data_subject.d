module uim.platform.data_retention.presentation.http.controllers.data_subject;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

class DataSubjectController : ManageHttpController {
    private ManageDataSubjectsUseCase usecase;

    this(ManageDataSubjectsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/data-subjects", &handleCreate);
        router.get("/api/v1/data-retention/data-subjects", &handleList);
        router.get("/api/v1/data-retention/data-subjects/*", &handleGet);
        router.put("/api/v1/data-retention/data-subjects/*", &handleUpdate);
        router.post("/api/v1/data-retention/data-subjects/*/block", &handleBlock);
        router.delete_("/api/v1/data-retention/data-subjects/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDataSubjectRequest r;
        r.tenantId = tenantId;
        r.roleId = RoleId(data.getString("roleId"));
        r.applicationGroupId = ApplicationGroupId(data.getString("applicationGroupId"));
        r.externalId = data.getString("externalId");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataSubject(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject.set("id", result.id);
        return successResponse(
            "Data subject created successfully", "Created", 201, response);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDataSubjects(tenantId);
        auto jarr = Json.emptyArray;
        foreach (ds; items) {
            jarr ~= Json.emptyObject
                .set("id", ds.id.value).set("externalId", ds.externalId)
                .set("roleId", ds.roleId.value)
                .set("applicationGroupId", ds.applicationGroupId.value)
                .set("lifecycleStatus", ds.lifecycleStatus.to!string);
        }
        return successResponse(
            "Data subjects retrieved successfully", "Retrieved", 200, Json.emptyObject.set("items", jarr)
                .set("totalCount", items.length));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto ds = usecase.getDataSubject(tenantId, id);
        if (ds.isNull)
            return errorResponse("Data subject not found", 404);

        auto response = Json.emptyObject
            .set("id", ds.id.value).set("externalId", ds.externalId)
            .set("roleId", ds.roleId.value)
            .set("applicationGroupId", ds.applicationGroupId.value)
            .set("lifecycleStatus", ds.lifecycleStatus.to!string)
            .set("endOfPurposeDate", ds.endOfPurposeDate)
            .set("endOfRetentionDate", ds.endOfRetentionDate);

        res.writeJsonBody(response, 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto data = precheck.data;
        UpdateDataSubjectRequest r;
        r.tenantId = tenantId;
        r.lifecycleStatus = data.getString("lifecycleStatus");
        r.roleId = RoleId(data.getString("roleId"));

        auto result = usecase.updateDataSubject(id, r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject.set("id", result.id);
        return successResponse("Data subject updated successfully", "Updated", 200, response);
    }

    protected Json blockHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto parts = path.split("/");
        string id = "";
        if (parts.length >= 6)
            id = parts[$ - 2];
        auto dataSubjectId = DataSubjectId(id);
        if (dataSubjectId.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto result = usecase.blockDataSubject(tenantId, dataSubjectId);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject
            .set("id", result.id)
            .set("lifecycleStatus", "blocked");

        return successResponse("Data subject blocked successfully", "Blocked", 200, response);
    }

    mixin(HandleTemplate!("handleBlock", "blockHandler"));

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data subject ID", 400);

        auto result = usecase.deleteDataSubject(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject.set("id", result.id);

        return successResponse("Data subject deleted successfully", "Deleted", 200, response);
    }
}
