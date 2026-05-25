/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.refresh_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class RefreshTokenController : PlatformController {
    private ManageRefreshTokensUseCase usecase;

    this(ManageRefreshTokensUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/oauth/refresh-tokens", &handleList);
        router.get("/api/v1/oauth/refresh-tokens/*", &handleGet);
        router.post("/api/v1/oauth/refresh-tokens", &handleCreate);
        router.post("/api/v1/oauth/refresh-tokens/revoke/*", &handleRevoke);
        router.delete_("/api/v1/oauth/refresh-tokens/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listTokens(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Refresh tokens retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = RefreshTokenId(extractIdFromPath(path));

            auto e = usecase.getToken(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Refresh token not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;

            RefreshTokenDTO dto;
            dto.tokenId = j.getString("id");
            dto.tenantId = tenantId;
            dto.tokenValue = j.getString("tokenValue");
            dto.clientId = j.getString("clientId");
            dto.userId = j.getString("userId");
            dto.scopes = j.getString("scopes");
            dto.accessTokenId = j.getString("accessTokenId");
            dto.expiresAt = 0;
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createToken(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Refresh token created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = RefreshTokenId(extractIdFromPath(path));

            auto result = usecase.revokeToken(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Refresh token revoked");

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
            auto id = RefreshTokenId(extractIdFromPath(path));

            auto result = usecase.deleteToken(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Refresh token deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
