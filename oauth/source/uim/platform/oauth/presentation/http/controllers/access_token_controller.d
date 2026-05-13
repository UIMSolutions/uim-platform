/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.access_token_controller;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AccessTokenController : PlatformController {
    private ManageAccessTokensUseCase usecase;

    this(ManageAccessTokensUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/oauth/access-tokens", &handleList);
        router.get("/api/v1/oauth/access-tokens/*", &handleGet);
        router.post("/api/v1/oauth/access-tokens", &handleCreate);
        router.post("/api/v1/oauth/access-tokens/revoke/*", &handleRevoke);
        router.delete_("/api/v1/oauth/access-tokens/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = usecase.list(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Access tokens retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = usecase.getById(AccessTokenId(id));
            if (e.isNull) { writeError(res, 404, "Access token not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            AccessTokenDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.tokenValue = j.getString("tokenValue");
            dto.clientId = j.getString("clientId");
            dto.userId = j.getString("userId");
            dto.scopes = j.getString("scopes");
            dto.expiresAt = 0;
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Access token created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = usecase.revoke(AccessTokenId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Access token revoked");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AccessTokenId(extractIdFromPath(path));
            auto result = usecase.delete(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Access token deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
