module uim.platform.service_manager.presentation.http.controllers.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class LabelController : PlatformController {
    private ManageLabelsUseCase uc;

    this(ManageLabelsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/service-manager/labels", &handleList);
        router.get("/api/v1/service-manager/labels/*", &handleGet);
        router.post("/api/v1/service-manager/labels", &handleCreate);
        router.put("/api/v1/service-manager/labels/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/labels/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = uc.listByTenant(tenantId);
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

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = uc.getById(tenantId, LabelId(id));
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

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CreateLabelRequest r;
            r.resourceId = j.getString("resourceId");
            r.resourceType = j.getString("resourceType");
            r.key = j.getString("key");
            r.value = j.getString("value");

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
            UpdateLabelRequest r;
            r.key = j.getString("key");
            r.value = j.getString("value");

            auto result = uc.update(req.getTenantId, LabelId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto result = uc.remove(req.getTenantId, LabelId(id));
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
