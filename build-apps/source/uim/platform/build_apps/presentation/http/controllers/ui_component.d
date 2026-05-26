/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.ui_component;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class UIComponentController : ManageController {
    private ManageUIComponentsUseCase components;

    this(ManageUIComponentsUseCase components) {
        this.components = components;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/ui-components", &handleList);
        router.get("/api/v1/build-apps/ui-components/*", &handleGet);
        router.post("/api/v1/build-apps/ui-components", &handleCreate);
        router.put("/api/v1/build-apps/ui-components/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/ui-components/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();

            auto items = components.listUIComponents(tenantId);
            auto jarr = items.map!(e => e.uiComponenttoJson).array.toJson;
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "UI components retrieved");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = UIComponentId(precheck.id);

            auto e = components.getUIComponent(tenantId, id);
            if (e.isNull) { writeError(res, 404, "UI component not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId();
            auto j = req.json;

            UIComponentDTO dto;
            dto.uiComponentId = UIComponentId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.category = j.getString("category");
            dto.version_ = j.getString("version");
            dto.properties = j.getString("properties");
            dto.styleProperties = j.getString("styleProperties");
            dto.eventBindings = j.getString("eventBindings");
            dto.dataBindings = j.getString("dataBindings");
            dto.childComponents = j.getString("childComponents");
            dto.iconUrl = j.getString("iconUrl");
            dto.previewUrl = j.getString("previewUrl");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = components.createUIComponent(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "UI component created");

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
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto j = req.json;

            UIComponentDTO dto;
            dto.tenantId = tenantId;
            dto.uiComponentId = UIComponentId(precheck.id);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = components.updateUIComponent(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "UI component updated");
                
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
            auto tenantId = req.getTenantId();
            auto path = req.requestURI.to!string;
            auto id = UIComponentId(precheck.id);

            auto result = components.deleteUIComponent(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                  .set("message", "UI component deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
