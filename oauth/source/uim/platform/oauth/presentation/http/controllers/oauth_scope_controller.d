/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.oauth_scope_controller;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthScopeController : PlatformController {
    private ManageOAuthScopesUseCase usecase;

    this(ManageOAuthScopesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/oauth/scopes", &handleList);
        router.get("/api/v1/oauth/scopes/*", &handleGet);
        router.post("/api/v1/oauth/scopes", &handleCreate);
        router.put("/api/v1/oauth/scopes/*", &handleUpdate);
        router.delete_("/api/v1/oauth/scopes/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = usecase.list(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr);
            
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
            auto e = usecase.getById(OAuthScopeId(id));
            if (e.isNull) { writeError(res, 404, "OAuth scope not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            OAuthScopeDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.applicationId = j.getString("applicationId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth scope created");

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
            OAuthScopeDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "OAuth scope updated");

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
            auto id = extractIdFromPath(path);
            auto result = usecase.deleteOAuthScope(OAuthScopeId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "OAuth scope deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
