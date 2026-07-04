module uim.platform.data_retention.presentation.http.controllers.data_subject_role;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectRoleController : ManageHttpController {
    private ManageDataSubjectRolesUseCase usecase;

    this(ManageDataSubjectRolesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.post("/api/v1/data-retention/data-subject-roles", &handleCreate);
        router.get("/api/v1/data-retention/data-subject-roles", &handleList);
        router.get("/api/v1/data-retention/data-subject-roles/*", &handleGet);
        router.put("/api/v1/data-retention/data-subject-roles/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/data-subject-roles/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateDataSubjectRoleRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDataSubjectRole(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto response = Json.emptyObject
            .set("id", result.id)
            .set("name", r.name)
            .set("description", r.description)
            .set("isActive", true);

        return successResponse("Data subject role created successfully", "Created", 201, response);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listDataSubjectRoles(tenantId);
        auto jarr = Json.emptyArray;
        foreach (dsr; items) {
            jarr ~= Json.emptyObject
                .set("id", dsr.id.value).set("name", dsr.name)
                .set("description", dsr.description)
                .set("isActive", dsr.isActive);
        }

        auto responseData = Json.emptyObject
            .set("count", jarr.length)
            .set("resources", jarr);
        return successResponse("Data subject role list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectRoleId(precheck.id);

        auto dsr = usecase.getById(tenantId, id);
        if (dsr.isNull)
            return errorResponse("Data subject role not found", 404);

        auto responseData = dsr.toJson();
        return successResponse("Data subject role retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectRoleId(precheck.id);
        auto data = precheck.data;
        UpdateDataSubjectRoleRequest r;
        r.tenantId = tenantId;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.isActive = data.getBoolean("isActive", true);

        auto result = usecase.updateDataSubjectRole(tenantId, id, r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto response = Json.emptyObject
            .set("id", result.id)
            .set("name", r.name)
            .set("description", r.description)
            .set("isActive", r.isActive);

        return successResponse("Data subject role updated successfully", "Updated", 200, response);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataSubjectRoleId(precheck.id);

        auto result = usecase.deleteDataSubjectRole(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data subject role deleted successfully", "Deleted", 200, responseData);
    }
}
