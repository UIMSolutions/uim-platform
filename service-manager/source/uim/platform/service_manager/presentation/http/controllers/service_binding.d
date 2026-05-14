module uim.platform.service_manager.presentation.http.controllers.service_binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceBindingController : PlatformController {
    private ManageServiceBindingsUseCase usecase;

    this(ManageServiceBindingsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/service-manager/service-bindings", &handleList);
        router.get("/api/v1/service-manager/service-bindings/*", &handleGet);
        router.post("/api/v1/service-manager/service-bindings", &handleCreate);
        router.put("/api/v1/service-manager/service-bindings/*", &handleUpdate);
        router.delete_("/api/v1/service-manager/service-bindings/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listByTenant(tenantId);
            auto jarr = Json.emptyArray;
            foreach (e; items) {
                jarr ~= Json.emptyObject
                    .set("id", e.id.value).set("name", e.name)
                    .set("instanceId", e.instanceId.value)
                    .set("status", e.status.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = req.getTenantId;
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto e = usecase.getById(tenantId, ServiceBindingId(id));
            if (e.isNull) { writeError(res, 404, "Service binding not found"); return; }
            res.writeJsonBody(Json.emptyObject
                .set("id", e.id.value).set("name", e.name)
                .set("instanceId", e.instanceId.value)
                .set("status", e.status.to!string)
                .set("credentials", e.credentials)
                .set("createdAt", e.createdAt), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            CreateServiceBindingRequest r;
            r.name = j.getString("name");
            r.instanceId = j.getString("instanceId");
            r.parameters = j.getString("parameters");
            r.bindResource = j.getString("bindResource");
            r.context = j.getString("context");
            r.labels = j.getString("labels");

            auto result = usecase.create(req.getTenantId, r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = extractIdFromPath(req.requestURI.to!string);
            auto j = req.json;
            UpdateServiceBindingRequest r;
            r.name = j.getString("name");
            r.parameters = j.getString("parameters");
            r.labels = j.getString("labels");

            auto result = usecase.update(req.getTenantId, ServiceBindingId(id), r);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto id = ServiceBindingId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteServiceBinding(req.getTenantId, id);
            if (result.success) {
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.error); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
