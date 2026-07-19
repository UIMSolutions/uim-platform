/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.access_token;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class AccessTokenController : ManageHttpController {
    private ManageAccessTokensUseCase usecase;

    this(ManageAccessTokensUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/oauth/access-tokens", &handleList);
        router.get("/api/v1/oauth/access-tokens/*", &handleGet);
        router.post("/api/v1/oauth/access-tokens", &handleCreate);
        router.post("/api/v1/oauth/access-tokens/revoke/*", &handleRevoke);
        router.delete_("/api/v1/oauth/access-tokens/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listTokens(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("Access tokens retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = AccessTokenId(precheck.id);

        auto e = usecase.getToken(tenantId, id);
        if (e.isNull)
            return errorResponse("Access token not found", 404);

        return successResponse("Access token retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        AccessTokenDTO dto;
        dto.tokenId = AccessTokenId(precheck.id);
        dto.tenantId = tenantId;
        dto.tokenValue = data.getString("tokenValue");
        dto.clientId = data.getString("clientId");
        dto.userId = data.getString("userId");
        dto.scopes = data.getString("scopes");
        dto.expiresAt = 0;
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createToken(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Access token created successfully", "Created", 201, resp);
    }

    protected Json revokeHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AccessTokenId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid access token ID", 400);

        auto result = usecase.revokeToken(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Access token revoked successfully", "Revoked", 200, resp);
    }

    mixin(HandleTemplate!("handleRevoke", "revokeHandler"));

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = AccessTokenId(precheck.id);

        auto result = usecase.deleteToken(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Access token deleted successfully", "Deleted", 200, resp);
    }
}
