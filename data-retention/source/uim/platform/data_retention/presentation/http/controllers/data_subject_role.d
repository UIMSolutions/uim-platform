module uim.platform.data_retention.presentation.http.controllers.data_subject_role;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectRoleController : ManageController {
    private ManageDataSubjectRolesUseCase usecase;

    this(ManageDataSubjectRolesUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.post("/api/v1/data-retention/data-subject-roles", &handleCreate);
        router.get("/api/v1/data-retention/data-subject-roles", &handleList);
        router.get("/api/v1/data-retention/data-subject-roles/*", &handleGet);
        router.put("/api/v1/data-retention/data-subject-roles/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/data-subject-roles/*", &handleDelete);
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
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

                res.writeJsonBody(response, 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
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

            auto response = Json.emptyObject
                .set("items", jarr)
                .set("totalCount", items.length)
                .set("message", "Data subject roles retrieved");

            res.writeJsonBody(response, 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = DataSubjectRoleprecheck.id);

            auto dsr = usecase.getById(tenantId, id);
            if (dsr.isNull) { writeError(res, 404, "Data subject role not found"); return; }
            auto response = Json.emptyObject
                .set("id", dsr.id.value).set("name", dsr.name)
                .set("description", dsr.description)
                .set("isActive", dsr.isActive);

            res.writeJsonBody(response, 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = DataSubjectRoleprecheck.id);
            auto data = precheck.data;
            UpdateDataSubjectRoleRequest r;
            r.tenantId = tenantId;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.isActive = j.getBoolean("isActive", true);

            auto result = usecase.updateDataSubjectRole(tenantId, id, r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto response = Json.emptyObject
                    .set("id", result.id)
                    .set("name", r.name)
                    .set("description", r.description)
                    .set("isActive", r.isActive);

                res.writeJsonBody(response, 200);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = DataSubjectRoleprecheck.id);

            usecase.deleteDataSubjectRole(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
