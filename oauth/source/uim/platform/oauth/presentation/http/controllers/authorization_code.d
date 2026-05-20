/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.authorization_code;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AuthorizationCodeController : PlatformController {
    private ManageAuthorizationCodesUseCase usecase;

    this(ManageAuthorizationCodesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/oauth/authorization-codes", &handleList);
        router.get("/api/v1/oauth/authorization-codes/*", &handleGet);
        router.post("/api/v1/oauth/authorization-codes", &handleCreate);
        router.post("/api/v1/oauth/authorization-codes/use/*", &handleMarkUsed);
        router.delete_("/api/v1/oauth/authorization-codes/*", &handleDelete);
    }

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto items = usecase.listCodes(tenantId);
            auto jarr = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Authorization codes retrieved successfully");

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
            auto e = usecase.getCode(req.getTenantId, AuthorizationCodeId(id));
            if (e.isNull) {
                writeError(res, 404, "Authorization code not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;

            auto j = req.json;
            AuthorizationCodeDTO dto;
            dto.codeId = AuthorizationCodeId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.code = j.getString("code");
            dto.clientId = j.getString("clientId");
            dto.userId = j.getString("userId");
            dto.redirectUri = j.getString("redirectUri");
            dto.scopes = j.getString("scopes");
            dto.expiresAt = 0;
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createCode(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Authorization code created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleMarkUsed(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AuthorizationCodeId(extractIdFromPath(path));

            auto result = usecase.markUsedCode(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", id)
                    .set("message", "Authorization code marked as used");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AuthorizationCodeId(extractIdFromPath(path));
            auto result = usecase.deleteCode(tenantId, id);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("message", "Authorization code deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.errorMessage);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
