/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.ui_component;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class UIComponentController : PlatformController {
    private ManageUIComponentsUseCase uc;

    this(ManageUIComponentsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/build-apps/ui-components", &handleList);
        router.get("/api/v1/build-apps/ui-components/*", &handleGet);
        router.post("/api/v1/build-apps/ui-components", &handleCreate);
        router.put("/api/v1/build-apps/ui-components/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/ui-components/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.uiComponentToJson();
            auto resp = Json.emptyObject;
            resp["count"] = Json(items.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(UIComponentId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "UI component not found"); return; }
            res.writeJsonBody(e.uiComponentToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            UIComponentDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
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
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("UI component created");
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
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            UIComponentDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("UI component updated");
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
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(UIComponentId(id));
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("UI component deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
