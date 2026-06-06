/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.refresh_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class RefreshTokenController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listTokens(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Refresh token list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = RefreshTokenId(precheck.id);

        auto e = usecase.getToken(tenantId, id);
        if (item.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = item.toJson();
        return successResponse("Refresh token retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        RefreshTokenDTO dto;
        dto.tokenId = precheck.id;
        dto.tenantId = tenantId;
        dto.tokenValue = data.getString("tokenValue");
        dto.clientId = data.getString("clientId");
        dto.userId = data.getString("userId");
        dto.scopes = data.getString("scopes");
        dto.accessTokenId = data.getString("accessTokenId");
        dto.expiresAt = 0;
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createToken(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Refresh token created successfully", "Created", 201, responseData);
    }

    protected Json revokeHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = RefreshTokenId(precheck.id);

        auto result = usecase.revokeToken(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("", 0, responseData);
    }

    protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = revokeHandler(req);
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
        auto path = precheck.path;
        auto id = RefreshTokenId(precheck.id);

        auto result = usecase.deleteToken(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Refresh token deleted successfully", 200, responseData);
    }
}
