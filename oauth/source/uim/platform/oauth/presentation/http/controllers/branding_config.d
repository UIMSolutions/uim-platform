/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.branding_config;

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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listConfigs(tenantId);
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

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BrandingConfigId(extractIdFromPath(path));

            auto e = usecase.getConfig(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Branding config not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            BrandingConfigDTO dto;
            dto.configId = BrandingConfigId(j.getString("id"));
            dto.tenantId = tenantId;
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

            auto result = usecase.createConfig(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Branding config created");
                
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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            BrandingConfigDTO dto;
            dto.tenantId = tenantId;
            dto.configId = BrandingConfigId(extractIdFromPath(path));
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

            auto result = usecase.updateConfig(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Branding config updated");
                
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
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BrandingConfigId(extractIdFromPath(path));
            auto result = usecase.deleteConfig(tenantId, id);

            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Branding config deleted");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
    