module uim.platform.data_retention.presentation.http.controllers.data_subject_role;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DataSubjectRoleController : PlatformController {
    private ManageDataSubjectRolesUseCase uc;

    this(ManageDataSubjectRolesUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/data-subject-roles", &handleCreate);
        router.get("/api/v1/data-retention/data-subject-roles", &handleList);
        router.get("/api/v1/data-retention/data-subject-roles/*", &handleGet);
        router.put("/api/v1/data-retention/data-subject-roles/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/data-subject-roles/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateDataSubjectRoleRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
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
            foreach (dsr; items) {
                jarr ~= Json.emptyObject
                    .set("id", dsr.id.value).set("name", dsr.name)
                    .set("description", dsr.description)
                    .set("isActive", dsr.isActive);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto dsr = uc.getById(id);
            if (dsr.id.isEmpty) { writeError(res, 404, "Data subject role not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", dsr.id.value).set("name", dsr.name)
                .set("description", dsr.description)
                .set("isActive", dsr.isActive), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateDataSubjectRoleRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.isActive = j.getBoolean("isActive", true);

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
