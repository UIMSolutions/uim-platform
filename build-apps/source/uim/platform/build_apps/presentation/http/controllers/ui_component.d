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
            auto data = precheck.data;

            UIComponentDTO dto;
            dto.uiComponentId = UIComponentId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.category = data.getString("category");
            dto.version_ = data.getString("version");
            dto.properties = data.getString("properties");
            dto.styleProperties = data.getString("styleProperties");
            dto.eventBindings = data.getString("eventBindings");
            dto.dataBindings = data.getString("dataBindings");
            dto.childComponents = data.getString("childComponents");
            dto.iconUrl = data.getString("iconUrl");
            dto.previewUrl = data.getString("previewUrl");
            dto.createdBy = UserId(data.getString("createdBy"));

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
            auto data = precheck.data;

            UIComponentDTO dto;
            dto.tenantId = tenantId;
            dto.uiComponentId = UIComponentId(precheck.id);
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.version_ = data.getString("version");
            dto.updatedBy = UserId(data.getString("updatedBy"));

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
