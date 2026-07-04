/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.identity_provider;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class IdentityProviderController : ManageHttpController {
    private ManageIdentityProvidersUseCase identityProviders;

    this(ManageIdentityProvidersUseCase identityProviders) {
        this.identityProviders = identityProviders;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/identity-providers", &handleList);
        router.get("/api/v1/customer-identity/identity-providers/*", &handleGet);
        router.post("/api/v1/customer-identity/identity-providers", &handleCreate);
        router.put("/api/v1/customer-identity/identity-providers/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/identity-providers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = identityProviders.listIdentityProviders(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Identity providers retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        IdentityProviderDTO dto;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.providerType = data.getString("providerType");
        dto.clientId = data.getString("clientId");
        dto.clientSecret = data.getString("clientSecret");
        dto.issuerUrl = data.getString("issuerUrl");
        dto.metadataUrl = data.getString("metadataUrl");
        dto.redirectUri = data.getString("redirectUri");
        dto.attributeMapping = data.getString("attributeMapping");
        dto.scopes = data.getString("scopes");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = identityProviders.createIdentityProvider(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Identity provider created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = IdentityProviderId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Identity Provider ID").set("status", "error").set("statusCode", 400);

        auto e = identityProviders.getIdentityProvider(tenantId, id);
        if (e.isNull)
            return errorResponse("Identity provider not found", 404);

        return successResponse("Identity provider retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = IdentityProviderId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Identity Provider ID").set("status", "error").set("statusCode", 400);

        auto data = precheck.data;
        IdentityProviderDTO dto;
        dto.identityProviderId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.issuerUrl = data.getString("issuerUrl");
        dto.metadataUrl = data.getString("metadataUrl");
        dto.redirectUri = data.getString("redirectUri");
        dto.attributeMapping = data.getString("attributeMapping");
        dto.scopes = data.getString("scopes");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = identityProviders.updateIdentityProvider(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Identity provider updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = IdentityProviderId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Identity Provider ID").set("status", "error").set("statusCode", 400);

        auto result = identityProviders.deleteIdentityProvider(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Identity provider deleted successfully", "Deleted", 200, responseData);
    }
}
