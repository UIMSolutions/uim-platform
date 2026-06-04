/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.authorization_code;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AuthorizationCodeController : ManageHttpController {
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
            .set("resources", jarr);

        return successResponse("Authorization codes retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = AuthorizationCodeId(precheck.id);
        auto e = usecase.getCode(tenantId, id);
        if (e.isNull)
            return errorResponse("Authorization code not found", 404);

        return successResponse("Authorization code retrieved successfully", "Retrieved", 200, e
                .toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AuthorizationCodeId(precheck.id);

        auto data = precheck.data;
        AuthorizationCodeDTO dto;
        dto.codeId = id;
        dto.tenantId = precheck.tenantId;
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

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Authorization code created successfully", "Created", 201, resp);
    }

    protected Json markUsedHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AuthorizationCodeId(precheck.id);

        auto result = usecase.markUsedCode(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject
            .set("id", id);
        return successResponse("Authorization code marked as used successfully", "Updated", 200, resp);
    }

    protected void handleMarkUsed(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = markUsedHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AuthorizationCodeId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid authorization code ID", 400);
            
        auto result = usecase.deleteCode(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Authorization code deleted successfully", "Deleted", 200, resp);
    }
}
