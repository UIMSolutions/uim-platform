/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.branding_config;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class BrandingConfigController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listConfigs(tenantId);
            auto list = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Branding configs retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto id = BrandingConfigId(precheck.id);

            auto e = usecase.getConfig(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Branding config not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
            BrandingConfigDTO dto;
            dto.configId = BrandingConfigId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.logoUrl = data.getString("logoUrl");
            dto.backgroundUrl = data.getString("backgroundUrl");
            dto.primaryColor = data.getString("primaryColor");
            dto.secondaryColor = data.getString("secondaryColor");
            dto.pageTitle = data.getString("pageTitle");
            dto.footerText = data.getString("footerText");
            dto.customCss = data.getString("customCss");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createConfig(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
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

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto data = precheck.data;
            BrandingConfigDTO dto;
            dto.tenantId = tenantId;
            dto.configId = BrandingConfigId(precheck.id);
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.logoUrl = data.getString("logoUrl");
            dto.backgroundUrl = data.getString("backgroundUrl");
            dto.primaryColor = data.getString("primaryColor");
            dto.secondaryColor = data.getString("secondaryColor");
            dto.pageTitle = data.getString("pageTitle");
            dto.footerText = data.getString("footerText");
            dto.customCss = data.getString("customCss");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateConfig(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
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

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
            auto path = precheck.path;
            auto id = BrandingConfigId(precheck.id);
            auto result = usecase.deleteConfig(tenantId, id);

            if (result.hasError)
            return errorResponse(result.message, 400);
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
    