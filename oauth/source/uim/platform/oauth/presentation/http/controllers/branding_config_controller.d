/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.branding_config_controller;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class BrandingConfigController : PlatformController {
    private ManageBrandingConfigsUseCase uc;

    this(ManageBrandingConfigsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/oauth/branding-configs", &handleList);
        router.get("/api/v1/oauth/branding-configs/*", &handleGet);
        router.post("/api/v1/oauth/branding-configs", &handleCreate);
        router.put("/api/v1/oauth/branding-configs/*", &handleUpdate);
        router.delete_("/api/v1/oauth/branding-configs/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.brandingConfigToJson();
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Branding configs retrieved successfully");

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
            auto e = uc.getById(BrandingConfigId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Branding config not found"); return; }
            res.writeJsonBody(e.brandingConfigToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            BrandingConfigDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.logoUrl = j.getString("logoUrl");
            dto.backgroundUrl = j.getString("backgroundUrl");
            dto.primaryColor = j.getString("primaryColor");
            dto.secondaryColor = j.getString("secondaryColor");
            dto.pageTitle = j.getString("pageTitle");
            dto.footerText = j.getString("footerText");
            dto.customCss = j.getString("customCss");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Branding config created");
                
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
            BrandingConfigDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.logoUrl = j.getString("logoUrl");
            dto.backgroundUrl = j.getString("backgroundUrl");
            dto.primaryColor = j.getString("primaryColor");
            dto.secondaryColor = j.getString("secondaryColor");
            dto.pageTitle = j.getString("pageTitle");
            dto.footerText = j.getString("footerText");
            dto.customCss = j.getString("customCss");
            dto.modifiedBy = j.getString("modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Branding config updated");
                
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
            auto result = uc.remove(BrandingConfigId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Branding config deleted");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
    