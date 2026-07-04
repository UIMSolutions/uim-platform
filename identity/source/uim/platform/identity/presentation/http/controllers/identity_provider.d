/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.identity_provider;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class IdentityProviderController : ManageHttpController {
    private ManageIdentityProvidersUseCase usecase;

    this(ManageIdentityProvidersUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/ias/identity-providers", &handleList);
        router.get("/api/v1/ias/identity-providers/*", &handleGet);
        router.post("/api/v1/ias/identity-providers", &handleCreate);
        router.put("/api/v1/ias/identity-providers/*", &handleUpdate);
        router.delete_("/api/v1/ias/identity-providers/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listIdentityProviders(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        return successResponse("Identity providers retrieved successfully", "Retrieved", 200, Json.emptyObject
                .set("count", items.length)
                .set("resources", list));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = IdentityProviderId(precheck.id);
        auto e = usecase.getIdentityProvider(tenantId, id);
        if (e.isNull)
            return errorResponse("Identity provider not found", 404);
        return successResponse("Identity provider retrieved successfully", "Retrieved", 200, Json.emptyObject
                .set("resource", e.toJson));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        IdentityProviderDTO dto;
        dto.idpId = IdentityProviderId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.type_ = data.getString("type");
        dto.entityId = data.getString("entityId");
        dto.ssoUrl = data.getString("ssoUrl");
        dto.sloUrl = data.getString("sloUrl");
        dto.metadataUrl = data.getString("metadataUrl");
        dto.clientId = data.getString("clientId");
        dto.isDefault = data.getBoolean("isDefault");

        auto result = usecase.createIdentityProvider(dto);
        if (!result.success)
            return errorResponse(result.message, 400);
        return successResponse("Identity provider created successfully", "Created", 201, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        IdentityProviderDTO dto;
        dto.idpId = IdentityProviderId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.ssoUrl = data.getString("ssoUrl");
        dto.sloUrl = data.getString("sloUrl");
        dto.metadataUrl = data.getString("metadataUrl");
        dto.status = data.getString("status");
        dto.isDefault = data.getBoolean("isDefault");

        auto result = usecase.updateIdentityProvider(dto);
        if (!result.success)
            return errorResponse(result.message, 404);
        return successResponse("Identity provider updated successfully", "Updated", 200, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = IdentityProviderId(precheck.id);
        auto result = usecase.deleteIdentityProvider(tenantId, id);
        if (!result.success)
            return errorResponse(result.message, 404);
        return successResponse("Identity provider deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result
                .id));
    }
}
