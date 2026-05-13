module uim.platform.data_retention.presentation.http.controllers.application_group;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ApplicationGroupController : PlatformController {
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

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            CreateApplicationGroupRequest r;
            r.tenantId = tenantId;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.scope_ = j.getString("scope");
            r.createdBy = UserId(j.getString("createdBy"));

            foreach (item; j.getArray("applicationIds")) {
                r.applicationIds ~= getString(item, "");
            }

            auto result = usecase.createApplicationGroup(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listApplicationGroups(tenantId);
            auto jarr = Json.emptyArray;
            foreach (ag; items) {
                jarr ~= Json.emptyObject
                    .set("id", ag.id.value).set("name", ag.name)
                    .set("description", ag.description)
                    .set("scope", ag.scope_.to!string)
                    .set("isActive", ag.isActive);
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
            auto id = ApplicationGroupControllerId(extractIdFromPath(req.requestURI.to!string));
            auto ag = usecase.getApplicationGroup(tenantId, id);
            if (ag.isNull) {
                writeError(res, 404, "Application group not found");
                return;
            }

            auto response = Json.emptyObject
                .set("id", ag.id.value)
                .set("name", ag.name)
                .set("description", ag.description)
                .set("scope", ag.scope_.to!string)
                .set("isActive", ag.isActive);
                
            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ApplicationGroupControllerId(extractIdFromPath(req.requestURI.to!string));
            auto j = req.json;

            UpdateApplicationGroupRequest r;
            r.tenantId = tenantId;
            r.applicationGroupId = id;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.scope_ = j.getString("scope");
            r.isActive = j.getBoolean("isActive", true);

            auto result = usecase.updateApplicationGroup(r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ApplicationGroupControllerId(extractIdFromPath(req.requestURI.to!string));

            usecase.deleteApplicationGroup(tenantId, id);
            res.writeJsonBody(Json.emptyObject, 204);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
