module uim.platform.service_manager.presentation.http.controllers.service_instance;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceInstanceController : PlatformController {
    private ManageServiceInstancesUseCase uc;

    this(ManageServiceInstancesUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/service-instances", &handleList);
        router.get("/api/v1/service-manager/service-instances/*", &handleGet);
        router.post("/api/v1/service-manager/service-instances", &handleCreate);
        router.put("/api/v1/service-manager/service-instances/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-instances/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.listByTenant(tenantId);
            auto jarr = Json.emptyArray;
            foreach (e; items) {
                jarr ~= Json.emptyObject
                    .set("id", e.id.value).set("name", e.name)
                    .set("planId", e.planId.value)
                    .set("status", e.status.to!string)
                    .set("shared", e.shared)
                    .set("usable", e.usable);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, ServiceInstanceId(id));
            if (e is null) { writeError(res, 404, "Service instance not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("planId", e.planId.value)
                .set("offeringId", e.offeringId.value)
                .set("platformId", e.platformId.value)
                .set("status", e.status.to!string)
                .set("shared", e.shared)
                .set("usable", e.usable)
                .set("dashboardUrl", e.dashboardUrl)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateServiceInstanceRequest r;
            r.name = j.getString("name");
            r.planId = j.getString("planId");
            r.offeringId = j.getString("offeringId");
            r.platformId = j.getString("platformId");
            r.context = j.getString("context");
            r.parameters = j.getString("parameters");
            r.labels = j.getString("labels");

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
            UpdateServiceInstanceRequest r;
            r.name = j.getString("name");
            r.planId = j.getString("planId");
            r.parameters = j.getString("parameters");
            r.labels = j.getString("labels");

            auto result = uc.update(req.getTenantId, ServiceInstanceId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, ServiceInstanceId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
