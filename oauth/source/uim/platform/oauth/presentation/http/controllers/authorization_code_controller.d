/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.authorization_code_controller;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AuthorizationCodeController : PlatformController {
    private ManageAuthorizationCodesUseCase uc;

    this(ManageAuthorizationCodesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/oauth/authorization-codes", &handleList);
        router.get("/api/v1/oauth/authorization-codes/*", &handleGet);
        router.post("/api/v1/oauth/authorization-codes", &handleCreate);
        router.post("/api/v1/oauth/authorization-codes/use/*", &handleMarkUsed);
        router.delete_("/api/v1/oauth/authorization-codes/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items)
                jarr ~= e.authorizationCodeToJson();
            auto resp = Json.emptyObject
                .set("count", Json(items.length))
                .set("resources", jarr)
                .set("message", "Authorization codes retrieved successfully");

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
            auto e = uc.getById(AuthorizationCodeId(id));
            if (e.id.value.length == 0) {
                writeError(res, 404, "Authorization code not found");
                return;
            }
            res.writeJsonBody(e.authorizationCodeToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            AuthorizationCodeDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.code = j.getString("code");
            dto.clientId = j.getString("clientId");
            dto.userId = j.getString("userId");
            dto.redirectUri = j.getString("redirectUri");
            dto.scopes = j.getString("scopes");
            dto.expiresAt = 0;
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Authorization code created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleMarkUsed(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.markUsed(AuthorizationCodeId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", id)
                    .set("message", "Authorization code marked as used");

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
            auto result = uc.remove(AuthorizationCodeId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Authorization code deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
