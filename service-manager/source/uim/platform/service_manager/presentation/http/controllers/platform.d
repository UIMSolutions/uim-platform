module uim.platform.service_manager.presentation.http.controllers.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class EnvironmentController : PlatformController {
    private ManagePlatformsUseCase uc;

    this(ManagePlatformsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/platforms", &handleList);
        router.get("/api/v1/service-manager/platforms/*", &handleGet);
        router.post("/api/v1/service-manager/platforms", &handleCreate);
        router.put("/api/v1/service-manager/platforms/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/platforms/*", &handleDelete);
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
                    .set("type", e.type.to!string)
                    .set("status", e.status.to!string)
                    .set("region", e.region);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, PlatformId(id));
            if (e.isNull) { writeError(res, 404, "Platform not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("description", e.description)
                .set("type", e.type.to!string)
                .set("status", e.status.to!string)
                .set("brokerUrl", e.brokerUrl)
                .set("region", e.region)
                .set("subaccountId", e.subaccountId)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreatePlatformRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.brokerUrl = j.getString("brokerUrl");
            r.credentials = j.getString("credentials");
            r.region = j.getString("region");
            r.subaccountId = j.getString("subaccountId");

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
            UpdatePlatformRequest r;
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.type = j.getString("type");
            r.brokerUrl = j.getString("brokerUrl");
            r.credentials = j.getString("credentials");
            r.region = j.getString("region");

            auto result = uc.update(req.getTenantId, PlatformId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, PlatformId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
