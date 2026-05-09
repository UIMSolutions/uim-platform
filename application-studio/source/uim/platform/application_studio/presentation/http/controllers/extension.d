/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.extension;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ExtensionController : PlatformController {
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listExtensions(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {   
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = ExtensionId(extractIdFromPath(path));
            auto e = usecase.getExtension(tenantId, id);
            if (e.id.isEmpty) { writeError(res, 404, "Extension not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            ExtensionDTO dto;
            dto.extensionId = ExtensionId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.publisher = j.getString("publisher");
            dto.category = j.getString("category");
            dto.dependencies = j.getString("dependencies");
            dto.capabilities = j.getString("capabilities");
            dto.iconUrl = j.getString("iconUrl");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto tenantId = req.getTenantId;
            auto result = usecase.createExtension(tenantId, dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Extension created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            
            ExtensionDTO dto;
            dto.extensionId = ExtensionId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateExtension(tenantId, dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Extension updated");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto path = req.requestURI.to!string;
            auto id = ExtensionId(extractIdFromPath(path));
            auto result = usecase.deleteExtension(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Extension deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
