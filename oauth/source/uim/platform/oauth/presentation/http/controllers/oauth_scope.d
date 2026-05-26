/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.oauth_scope;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthScopeController : ManageController {
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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listScopes(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = OAuthScopeId(precheck.id);

            auto e = usecase.getScope(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "OAuth scope not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            OAuthScopeDTO dto;
            dto.tenantId = tenantId;
            dto.scopeId = OAuthScopeId(j.getString("id"));
            dto.applicationId = j.getString("applicationId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createScope(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth scope created");

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
            OAuthScopeDTO dto;
            dto.tenantId = tenantId;
            dto.scopeId = OAuthScopeId(precheck.id);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateScope(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth scope updated");

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
            auto id = OAuthScopeId(precheck.id);
            auto result = usecase.deleteOAuthScope(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "OAuth scope deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
