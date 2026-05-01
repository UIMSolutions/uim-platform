/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.application;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ApplicationController : PlatformController {
    private ManageApplicationsUseCase uc;

    this(ManageApplicationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/build-apps/applications", &handleList);
        router.get("/api/v1/build-apps/applications/*", &handleGet);
        router.post("/api/v1/build-apps/applications", &handleCreate);
        router.put("/api/v1/build-apps/applications/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/applications/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.applicationToJson();
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Applications retrieved");

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
            auto e = uc.getById(ApplicationId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Application not found"); return; }
            res.writeJsonBody(e.applicationToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            ApplicationDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.appType = j.getString("appType");
            dto.version_ = j.getString("version");
            dto.iconUrl = j.getString("iconUrl");
            dto.themeConfig = j.getString("themeConfig");
            dto.globalVariables = j.getString("globalVariables");
            dto.defaultLanguage = j.getString("defaultLanguage");
            dto.supportedLanguages = j.getString("supportedLanguages");
            dto.owner = j.getString("owner");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application created");

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
            ApplicationDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.iconUrl = j.getString("iconUrl");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Application updated");

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
            auto result = uc.remove(ApplicationId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Application deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
