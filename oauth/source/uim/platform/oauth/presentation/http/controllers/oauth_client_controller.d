/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.oauth_client_controller;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthClientController : PlatformController {
    private ManageOAuthClientsUseCase uc;

    this(ManageOAuthClientsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/oauth/clients", &handleList);
        router.get("/api/v1/oauth/clients/*", &handleGet);
        router.post("/api/v1/oauth/clients", &handleCreate);
        router.put("/api/v1/oauth/clients/*", &handleUpdate);
        router.delete_("/api/v1/oauth/clients/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (e; items)
                jarr ~= e.oauthClientToJson();
            auto resp = Json.emptyObject
                .set("count", Json(items.length))
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
            auto e = uc.getById(OAuthClientId(id));
            if (e.id.value.length == 0) {
                writeError(res, 404, "OAuth client not found");
                return;
            }
            res.writeJsonBody(e.oauthClientToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            OAuthClientDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.clientId = j.getString("clientId");
            dto.clientSecret = j.getString("clientSecret");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.clientType = j.getString("clientType");
            dto.redirectUris = j.getString("redirectUris");
            dto.allowedScopes = j.getString("allowedScopes");
            dto.grantTypes = j.getString("grantTypes");
            dto.accessTokenValidity = j.getString("accessTokenValidity").length > 0 ? 3600 : 3600;
            dto.refreshTokenValidity = j.getString("refreshTokenValidity").length > 0 ? 86400
                : 86400;
            dto.contacts = j.getString("contacts");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth client created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;

            auto path = req.requestURI.to!string;
            auto j = req.json;
            OAuthClientDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.redirectUris = j.getString("redirectUris");
            dto.allowedScopes = j.getString("allowedScopes");
            dto.contacts = j.getString("contacts");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth client updated");

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
            auto result = uc.remove(OAuthClientId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "OAuth client deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
