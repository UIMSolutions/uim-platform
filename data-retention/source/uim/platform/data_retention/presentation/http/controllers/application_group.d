module uim.platform.data_retention.presentation.http.controllers.application_group;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ApplicationGroupController : PlatformController {
    private ManageApplicationGroupsUseCase uc;

    this(ManageApplicationGroupsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.post("/api/v1/data-retention/application-groups", &handleCreate);
        router.get("/api/v1/data-retention/application-groups", &handleList);
        router.get("/api/v1/data-retention/application-groups/*", &handleGet);
        router.put("/api/v1/data-retention/application-groups/*", &handleUpdate);
        router.delete_("/api/v1/data-retention/application-groups/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateApplicationGroupRequest r;
            r.tenantId = req.getTenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.scope_ = j.getString("scope");
            r.createdBy = j.getString("createdBy");

            auto appIdsVal = "applicationIds" in j;
            if (appIdsVal !is null && (*appIdsVal).isArray) {
                foreach (item; *appIdsVal) {
                    r.applicationIds ~= getString(item, "");
                }
            }

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
            foreach (ag; items) {
                jarr ~= Json.emptyObject
                    .set("id", ag.id.value).set("name", ag.name)
                    .set("description", ag.description)
                    .set("scope", ag.scope_.to!string)
                    .set("isActive", ag.isActive);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto ag = uc.getById(id);
            if (ag.isNull) { writeError(res, 404, "Application group not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", ag.id.value).set("name", ag.name)
                .set("description", ag.description)
                .set("scope", ag.scope_.to!string)
                .set("isActive", ag.isActive), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateApplicationGroupRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.scope_ = j.getString("scope");
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
