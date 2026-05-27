module uim.platform.service_manager.presentation.http.controllers.service_instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceInstanceController : ManageController {
    private ManageServiceInstancesUseCase usecase;

    this(ManageServiceInstancesUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/service-manager/service-instances", &handleList);
        router.get("/api/v1/service-manager/service-instances/*", &handleGet);
        router.post("/api/v1/service-manager/service-instances", &handleCreate);
        router.put("/api/v1/service-manager/service-instances/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-instances/*", &handleDelete);
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
                    .set("id", e.id.value).set("name", e.name)
                    .set("planId", e.planId.value)
                    .set("status", e.status.to!string)
                    .set("shared", e.shared_)
                    .set("usable", e.usable);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getById(tenantId, ServiceInstanceId(id));
            if (e.isNull) { writeError(res, 404, "Service instance not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("planId", e.planId.value)
                .set("offeringId", e.offeringId.value)
                .set("platformId", e.platformId.value)
                .set("status", e.status.to!string)
                .set("shared", e.shared_)
                .set("usable", e.usable)
                .set("dashboardUrl", e.dashboardUrl)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            CreateServiceInstanceRequest r;
            r.name = data.getString("name");
            r.planId = data.getString("planId");
            r.offeringId = data.getString("offeringId");
            r.platformId = data.getString("platformId");
            r.context = data.getString("context");
            r.parameters = data.getString("parameters");
            r.labels = data.getString("labels");

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
            UpdateServiceInstanceRequest r;
            r.name = data.getString("name");
            r.planId = data.getString("planId");
            r.parameters = data.getString("parameters");
            r.labels = data.getString("labels");

            auto result = usecase.update(req.getTenantId, ServiceInstanceId(id), r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = precheck.id;
            auto result = usecase.deleteServiceInstance(req.getTenantId, ServiceInstanceId(id));
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
