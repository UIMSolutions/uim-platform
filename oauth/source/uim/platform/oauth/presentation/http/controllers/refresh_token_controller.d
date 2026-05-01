/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.refresh_token_controller;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class RefreshTokenController : PlatformController {
    private ManageRefreshTokensUseCase uc;

    this(ManageRefreshTokensUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/oauth/refresh-tokens", &handleList);
        router.get("/api/v1/oauth/refresh-tokens/*", &handleGet);
        router.post("/api/v1/oauth/refresh-tokens", &handleCreate);
        router.post("/api/v1/oauth/refresh-tokens/revoke/*", &handleRevoke);
        router.delete_("/api/v1/oauth/refresh-tokens/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.refreshTokenToJson();
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

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
            auto e = uc.getById(RefreshTokenId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Refresh token not found"); return; }
            res.writeJsonBody(e.refreshTokenToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            RefreshTokenDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.tokenValue = j.getString("tokenValue");
            dto.clientId = j.getString("clientId");
            dto.userId = j.getString("userId");
            dto.scopes = j.getString("scopes");
            dto.accessTokenId = j.getString("accessTokenId");
            dto.expiresAt = 0;
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Refresh token created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.revoke(RefreshTokenId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Refresh token revoked");

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
            auto result = uc.remove(RefreshTokenId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Refresh token deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
