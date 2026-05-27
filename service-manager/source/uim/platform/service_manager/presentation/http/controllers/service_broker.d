module uim.platform.service_manager.presentation.http.controllers.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceBrokerController : ManageController {
    private ManageServiceBrokersUseCase usecase;

    this(ManageServiceBrokersUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/service-manager/service-brokers", &handleList);
        router.get("/api/v1/service-manager/service-brokers/*", &handleGet);
        router.post("/api/v1/service-manager/service-brokers", &handleCreate);
        router.put("/api/v1/service-manager/service-brokers/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-brokers/*", &handleDelete);
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
                    .set("description", e.description)
                    .set("brokerUrl", e.brokerUrl)
                    .set("status", e.status.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
            auto e = usecase.getById(tenantId, ServiceBrokerId(id));
            if (e.isNull) { writeError(res, 404, "Service broker not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("brokerUrl", e.brokerUrl)
                .set("status", e.status.to!string)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            CreateServiceBrokerRequest r;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.brokerUrl = data.getString("brokerUrl");

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
            UpdateServiceBrokerRequest r;
            r.name = data.getString("name");
            r.description = data.getString("description");
            r.brokerUrl = data.getString("brokerUrl");

            auto result = usecase.update(req.getTenantId, ServiceBrokerId(id), r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = ServiceBrokerprecheck.id);
            auto result = usecase.delete(req.getTenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
