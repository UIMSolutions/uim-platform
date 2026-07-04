/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.presentation.http.controllers.oauth_client;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class OAuthClientController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listClients(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);

        return successResponse("OAuth clients retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = OAuthClientId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid OAuth client ID", 400);

        auto e = usecase.getClient(tenantId, id);
        if (e.isNull)
            return errorResponse("OAuth client not found", 404);

        return successResponse("OAuth client retrieved successfully", "Retrieved", 200, e.toJson);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        OAuthClientDTO dto;
        dto.tenantId = tenantId;
        dto.clientId = precheck.id;
        dto.tenantId = tenantId;
        dto.parentClientId = data.getString("clientId");
        dto.clientSecret = data.getString("clientSecret");
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.clientType = data.getString("clientType");
        dto.redirectUris = data.getString("redirectUris");
        dto.allowedScopes = data.getString("allowedScopes");
        dto.grantTypes = data.getString("grantTypes");
        dto.accessTokenValidity = data.getString("accessTokenValidity").length > 0 ? 3600 : 3600;
        dto.refreshTokenValidity = data.getString("refreshTokenValidity").length > 0 ? 86400 : 86400;
        dto.contacts = data.getString("contacts");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createClient(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("OAuth client created successfully", "Created", 201, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto data = precheck.data;
        OAuthClientDTO dto;
        dto.tenantId = tenantId;
        dto.clientId = OAuthClientId(precheck.id);
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.redirectUris = data.getString("redirectUris");
        dto.allowedScopes = data.getString("allowedScopes");
        dto.contacts = data.getString("contacts");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateClient(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("OAuth client updated successfully", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = OAuthClientId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid OAuth client ID", 400);

        auto result = usecase.deleteClient(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("OAuth client deleted successfully", 200, responseData);
    }
}
