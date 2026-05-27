/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.identity_provider;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class IdentityProviderController : ManageController {
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
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = identityProviders.listIdentityProviders(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

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
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Identity provider created").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = IdentityProviderId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Identity Provider ID").set("status", "error").set("statusCode", 400);

        auto e = identityProviders.getIdentityProvider(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Identity provider not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
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
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Identity provider updated").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = IdentityProviderId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Identity Provider ID").set("status", "error").set("statusCode", 400);

        auto result = identityProviders.deleteIdentityProvider(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Identity provider deleted").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 404);
    }
}
