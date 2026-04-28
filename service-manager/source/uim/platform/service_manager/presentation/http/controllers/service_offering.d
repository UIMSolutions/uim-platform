module uim.platform.service_manager.presentation.http.controllers.service_offering;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceOfferingController : PlatformController {
    private ManageServiceOfferingsUseCase uc;

    this(ManageServiceOfferingsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/service-offerings", &handleList);
        router.get("/api/v1/service-manager/service-offerings/*", &handleGet);
        router.post("/api/v1/service-manager/service-offerings", &handleCreate);
        router.put("/api/v1/service-manager/service-offerings/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-offerings/*", &handleDelete);
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
                    .set("catalogName", e.catalogName)
                    .set("status", e.status.to!string)
                    .set("category", e.category.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, ServiceOfferingId(id));
            if (e.isNull) { writeError(res, 404, "Service offering not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("catalogName", e.catalogName)
                .set("brokerId", e.brokerId.value)
                .set("status", e.status.to!string)
                .set("category", e.category.to!string)
                .set("bindable", e.bindable)
                .set("tags", e.tags)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateServiceOfferingRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.catalogName = j.getString("catalogName");
            r.brokerId = j.getString("brokerId");
            r.category = j.getString("category");
            r.tags = j.getString("tags");
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
            UpdateServiceOfferingRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.catalogName = j.getString("catalogName");
            r.tags = j.getString("tags");
            r.metadata = j.getString("metadata");

            auto result = uc.update(req.getTenantId, ServiceOfferingId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, ServiceOfferingId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
