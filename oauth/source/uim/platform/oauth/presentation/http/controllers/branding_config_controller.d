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
    private ManageBrandingConfigsUseCase usecase;

    this(ManageBrandingConfigsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/oauth/branding-configs", &handleList);
        router.get("/api/v1/oauth/branding-configs/*", &handleGet);
        router.post("/api/v1/oauth/branding-configs", &handleCreate);
        router.put("/api/v1/oauth/branding-configs/*", &handleUpdate);
        router.delete_("/api/v1/oauth/branding-configs/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = usecase.list(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Branding configs retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = usecase.getById(BrandingConfigId(id));
            if (e.isNull) { writeError(res, 404, "Branding config not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(dto);
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

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(dto);
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

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BrandingConfigId(extractIdFromPath(path));
            auto result = usecase.deleteBrandingConfig(id);
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
    