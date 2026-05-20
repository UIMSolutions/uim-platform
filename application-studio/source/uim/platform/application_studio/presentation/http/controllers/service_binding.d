/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.service_binding;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ServiceBindingController : PlatformController {
    private ManageServiceBindingsUseCase usecase;

    this(ManageServiceBindingsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/service-bindings", &handleList);
        router.get("/api/v1/application-studio/service-bindings/*", &handleGet);
        router.post("/api/v1/application-studio/service-bindings", &handleCreate);
        router.put("/api/v1/application-studio/service-bindings/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/service-bindings/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listServiceBindings(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Service bindings retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ServiceBindingId(extractIdFromPath(path));

            auto e = usecase.getServiceBinding(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Service binding not found");
                return;
            }
            res.writeJsonBody(e.serviceBindingToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            ServiceBindingDTO dto;
            dto.id = ServiceBindingId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.devSpaceId = DevSpaceId(j.getString("devSpaceId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.serviceUrl = j.getString("serviceUrl");
            dto.servicePath = j.getString("servicePath");
            dto.authType = j.getString("authType");
            dto.credentials = j.getString("credentials");
            dto.systemAlias = j.getString("systemAlias");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createServiceBinding(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Service binding created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            ServiceBindingDTO dto;
            dto.id = ServiceBindingId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.serviceUrl = j.getString("serviceUrl");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateServiceBinding(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Service binding updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ServiceBindingId(extractIdFromPath(path));

            auto result = usecase.deleteServiceBinding(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Service binding deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
