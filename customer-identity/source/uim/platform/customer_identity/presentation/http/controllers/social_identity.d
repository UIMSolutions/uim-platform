/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.social_identity;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class SocialIdentityController : ManageController {
    private ManageSocialIdentitiesUseCase socialIdentities;

    this(ManageSocialIdentitiesUseCase socialIdentities) {
        this.socialIdentities = socialIdentities;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/social-identities", &handleList);
        router.get("/api/v1/customer-identity/social-identities/*", &handleGet);
        router.post("/api/v1/customer-identity/social-identities", &handleCreate);
        router.put("/api/v1/customer-identity/social-identities/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/social-identities/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = socialIdentities.listSocialIdentities(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Social identities retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        SocialIdentityDTO dto;
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(data.getString("customerId"));
        dto.provider = data.getString("provider");
        dto.providerUserId = data.getString("providerUserId");
        dto.providerEmail = data.getString("providerEmail");
        dto.displayName = data.getString("displayName");
        dto.accessToken = data.getString("accessToken");
        dto.refreshToken = data.getString("refreshToken");
        dto.tokenExpiresAt = data.getInteger("tokenExpiresAt");
        dto.profileData = data.getString("profileData");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = socialIdentities.linkSocialIdentity(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Social identity linked successfully", 201, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SocialIdentityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Social Identity ID", 400);

        auto e = socialIdentities.getSocialIdentity(tenantId, id);
        if (e.isNull)
            return errorResponse("Social identity not found", 404);

        return successResponse("Social identity retrieved successfully", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SocialIdentityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Social Identity ID", 400);

        auto result = socialIdentities.unlinkSocialIdentity(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Social identity unlinked successfully", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = SocialIdentityId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Social Identity ID", 400);

        auto result = socialIdentities.deleteSocialIdentity(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Social identity deleted successfully", 200);
    }
}
