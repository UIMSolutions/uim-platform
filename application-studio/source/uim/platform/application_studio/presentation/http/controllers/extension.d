/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.extension;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ExtensionController : ManageController {
    private ManageExtensionsUseCase usecase;

    this(ManageExtensionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/extensions", &handleList);
        router.get("/api/v1/application-studio/extensions/*", &handleGet);
        router.post("/api/v1/application-studio/extensions", &handleCreate);
        router.put("/api/v1/application-studio/extensions/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/extensions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            
            auto items = usecase.listExtensions(tenantId);
            auto list = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {   
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = ExtensionId(precheck.id);
            auto e = usecase.getExtension(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Extension not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            ExtensionDTO dto;
            dto.extensionId = ExtensionId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.version_ = data.getString("version");
            dto.publisher = data.getString("publisher");
            dto.category = data.getString("category");
            dto.dependencies = data.getString("dependencies");
            dto.capabilities = data.getString("capabilities");
            dto.iconUrl = data.getString("iconUrl");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto tenantId = precheck.tenantId;
            auto result = usecase.createExtension(tenantId, dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Extension created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            
            ExtensionDTO dto;
            dto.extensionId = ExtensionId(precheck.id);
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.version_ = data.getString("version");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateExtension(tenantId, dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Extension updated");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            
            auto path = req.requestURI.to!string;
            auto id = ExtensionId(precheck.id);
            auto result = usecase.deleteExtension(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "Extension deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
