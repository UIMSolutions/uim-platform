module uim.platform.service_manager.presentation.http.controllers.service_broker;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceBrokerController : PlatformController {
    private ManageServiceBrokersUseCase uc;

    this(ManageServiceBrokersUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/service-brokers", &handleList);
        router.get("/api/v1/service-manager/service-brokers/*", &handleGet);
        router.post("/api/v1/service-manager/service-brokers", &handleCreate);
        router.put("/api/v1/service-manager/service-brokers/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-brokers/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.listByTenant(tenantId);
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

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, ServiceBrokerId(id));
            if (e is null) { writeError(res, 404, "Service broker not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("brokerUrl", e.brokerUrl)
                .set("status", e.status.to!string)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateServiceBrokerRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.brokerUrl = j.getString("brokerUrl");

            auto result = uc.create(req.getTenantId, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateServiceBrokerRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.brokerUrl = j.getString("brokerUrl");

            auto result = uc.update(req.getTenantId, ServiceBrokerId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, ServiceBrokerId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
