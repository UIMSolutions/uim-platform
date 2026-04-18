module uim.platform.service_manager.presentation.http.controllers.service_plan;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServicePlanController : PlatformController {
    private ManageServicePlansUseCase uc;

    this(ManageServicePlansUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/service-plans", &handleList);
        router.get("/api/v1/service-manager/service-plans/*", &handleGet);
        router.post("/api/v1/service-manager/service-plans", &handleCreate);
        router.put("/api/v1/service-manager/service-plans/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-plans/*", &handleDelete);
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
                    .set("offeringId", e.offeringId.value)
                    .set("pricing", e.pricing.to!string)
                    .set("free", e.free);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, ServicePlanId(id));
            if (e is null) { writeError(res, 404, "Service plan not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("offeringId", e.offeringId.value)
                .set("pricing", e.pricing.to!string)
                .set("free", e.free)
                .set("bindable", e.bindable)
                .set("maxInstances", e.maxInstances)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateServicePlanRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.catalogName = j.getString("catalogName");
            r.offeringId = j.getString("offeringId");
            r.pricing = j.getString("pricing");
            r.schemas = j.getString("schemas");
            r.metadata = j.getString("metadata");

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
            UpdateServicePlanRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.schemas = j.getString("schemas");
            r.metadata = j.getString("metadata");

            auto result = uc.update(req.getTenantId, ServicePlanId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, ServicePlanId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
