/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.oauth_client;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthClientController : ManageController {
    private ManageOAuthClientsUseCase usecase;

    this(ManageOAuthClientsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/oauth/clients", &handleList);
        router.get("/api/v1/oauth/clients/*", &handleGet);
        router.post("/api/v1/oauth/clients", &handleCreate);
        router.put("/api/v1/oauth/clients/*", &handleUpdate);
        router.delete_("/api/v1/oauth/clients/*", &handleDelete);
    }

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listClients(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "OAuth client list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = OAuthClientId(extractIdFromPath(path));

            auto e = usecase.getClient(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "OAuth client not found");
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

            OAuthClientDTO dto;
            dto.tenantId = tenantId;
            dto.clientId = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.parentClientId = j.getString("clientId");
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

            auto result = usecase.createClient(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth client created");

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

            OAuthClientDTO dto;
            dto.tenantId = tenantId;
            dto.clientId = OAuthClientId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.redirectUris = j.getString("redirectUris");
            dto.allowedScopes = j.getString("allowedScopes");
            dto.contacts = j.getString("contacts");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateClient(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "OAuth client updated");

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
            auto path = req.requestURI.to!string;
            auto tenantId = req.getTenantId;
            auto id = OAuthClientId(extractIdFromPath(path));
            
            auto result = usecase.deleteClient(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "OAuth client deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
