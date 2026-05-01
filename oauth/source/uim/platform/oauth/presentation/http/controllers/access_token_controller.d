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
    private ManageAccessTokensUseCase uc;

    this(ManageAccessTokensUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/oauth/access-tokens", &handleList);
        router.get("/api/v1/oauth/access-tokens/*", &handleGet);
        router.post("/api/v1/oauth/access-tokens", &handleCreate);
        router.post("/api/v1/oauth/access-tokens/revoke/*", &handleRevoke);
        router.delete_("/api/v1/oauth/access-tokens/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items) jarr ~= e.accessTokenToJson();
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "Access tokens retrieved successfully");

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
            auto e = uc.getById(AccessTokenId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Access token not found"); return; }
            res.writeJsonBody(e.accessTokenToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            AccessTokenDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.tokenValue = j.getString("tokenValue");
            dto.clientId = j.getString("clientId");
            dto.userId = j.getString("userId");
            dto.scopes = j.getString("scopes");
            dto.expiresAt = 0;
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
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

    private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.revoke(AccessTokenId(id));
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

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(AccessTokenId(id));
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
