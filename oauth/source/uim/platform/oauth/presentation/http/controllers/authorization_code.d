/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.authorization_code;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AuthorizationCodeController : ManageController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;


            auto items = usecase.listCodes(tenantId);
            auto list = items.map!(e => e.toJson).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Authorization codes retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;

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

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;

            auto data = precheck.data;
            AuthorizationCodeDTO dto;
            dto.codeId = AuthorizationCodeId(precheck.id);
            dto.tenantId = tenantId;
            dto.code = data.getString("code");
            dto.clientId = data.getString("clientId");
            dto.userId = data.getString("userId");
            dto.redirectUri = data.getString("redirectUri");
            dto.scopes = data.getString("scopes");
            dto.expiresAt = 0;
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createCode(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Authorization code created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleMarkUsed(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = AuthorizationCodeId(precheck.id);

            auto result = usecase.markUsedCode(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", id)
                    .set("message", "Authorization code marked as used");

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
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = AuthorizationCodeId(precheck.id);
            auto result = usecase.deleteCode(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "Authorization code deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
