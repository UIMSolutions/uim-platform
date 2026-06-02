module uim.platform.service_manager.presentation.http.controllers.service_binding;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ServiceBindingController : ManageController {
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
                    .set("instanceId", e.instanceId.value)
                    .set("status", e.status.to!string);
            }
            res.writeJsonBody(Json.emptyObject.set("items", jarr).set("totalCount", items.length), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            
            auto tenantId = precheck.tenantId;
            auto id = precheck.id;
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

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            CreateServiceBindingRequest r;
            r.name = data.getString("name");
            r.instanceId = data.getString("instanceId");
            r.parameters = data.getString("parameters");
            r.bindResource = data.getString("bindResource");
            r.context = data.getString("context");
            r.labels = data.getString("labels");

            auto result = usecase.create(req.getTenantId, r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 201);
            } else { writeError(res, 400, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            
            auto id = precheck.id;
            auto data = precheck.data;
            UpdateServiceBindingRequest r;
            r.name = data.getString("name");
            r.parameters = data.getString("parameters");
            r.labels = data.getString("labels");

            auto result = usecase.update(req.getTenantId, ServiceBindingId(id), r);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject.set("id", result.id), 200);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            
            auto id = ServiceBindingId(precheck.id);
            auto result = usecase.deleteServiceBinding(req.getTenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                res.writeJsonBody(Json.emptyObject, 204);
            } else { writeError(res, 404, result.message); }
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
