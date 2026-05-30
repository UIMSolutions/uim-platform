module uim.platform.service_manager.presentation.http.controllers.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class LabelController : ManageController {
    private ManageLabelsUseCase usecase;

    this(ManageLabelsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/service-manager/labels", &handleList);
        router.get("/api/v1/service-manager/labels/*", &handleGet);
        router.post("/api/v1/service-manager/labels", &handleCreate);
        router.put("/api/v1/service-manager/labels/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/labels/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            
            auto items = usecase.listByTenant(tenantId);
            auto jarr = Json.emptyArray;
            foreach (e; items) {
                jarr ~= Json.emptyObject
                    .set("id", e.id.value)
                    .set("resourceId", e.resourceId)
                    .set("resourceType", e.resourceType)
                    .set("key", e.key)
                    .set("value", e.value);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getById(tenantId, LabelId(id));
            if (e.isNull) { writeError(res, 404, "Label not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value)
                .set("resourceId", e.resourceId)
                .set("resourceType", e.resourceType)
                .set("key", e.key)
                .set("value", e.value)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateLabelRequest r;
            r.resourceId = data.getString("resourceId");
            r.resourceType = data.getString("resourceType");
            r.key = data.getString("key");
            r.value = data.getString("value");

            auto result = usecase.create(req.getTenantId, r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = precheck.id;
            auto data = precheck.data;
            UpdateLabelRequest r;
            r.key = data.getString("key");
            r.value = data.getString("value");

            auto result = usecase.update(req.getTenantId, LabelId(id), r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = precheck.id;
            auto result = usecase.deleteLabel(req.getTenantId, LabelId(id));
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
