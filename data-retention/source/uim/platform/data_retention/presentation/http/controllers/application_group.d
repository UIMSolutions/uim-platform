module uim.platform.data_retention.presentation.http.controllers.application_group;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ApplicationGroupController : ManageHttpController {
    private ManageApplicationGroupsUseCase usecase;

    this(ManageApplicationGroupsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/application-groups", &handleCreate);
        router.get("/api/v1/data-retention/application-groups", &handleList);
        router.get("/api/v1/data-retention/application-groups/*", &handleGet);
        router.put("/api/v1/data-retention/application-groups/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/application-groups/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listApplicationGroups(tenantId);
        auto jlist = Json.emptyArray;
        foreach (ag; items) {
            jlist ~= Json.emptyObject
                .set("id", ag.id.value).set("name", ag.name)
                .set("description", ag.description)
                .set("scope", ag.scope_.to!string)
                .set("isActive", ag.isActive);
        }
        auto responseData = Json.emptyObject
            .set("count", items.length)
            .set("resources", jlist);

        return successResponse("Application group list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        CreateApplicationGroupRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.scope_ = data.getString("scope");
        r.createdBy = UserId(data.getString("createdBy"));
        r.applicationsIds = data.getArray("applicationIds").map!(item => getString(item, "")).array;

        auto result = usecase.createApplicationGroup(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application group created successfully", "Created", 201, responseData);

    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ApplicationGroupId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid application group ID", 400);

        auto ag = usecase.getApplicationGroup(tenantId, id);
        if (ag.isNull)
            return errorResponse("Application group not found", 404);

        auto response = Json.emptyObject
            .set("id", ag.id.value)
            .set("name", ag.name)
            .set("description", ag.description)
            .set("scope", ag.scope_.to!string)
            .set("isActive", ag.isActive);

        return successResponse("Application group retrieved successfully", "Retrieved", 200, response);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = ApplicationGroupId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid application group ID", 400);

        UpdateApplicationGroupRequest r;
        r.tenantId = tenantId;
        r.applicationGroupId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.scope_ = data.getString("scope");
        r.isActive = data.getBoolean("isActive", true);

        auto result = usecase.updateApplicationGroup(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application group updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ApplicationGroupId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid application group ID", 400);

        auto result = usecase.deleteApplicationGroup(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application group deleted successfully", "Deleted", 204, responseData);
    }
}
