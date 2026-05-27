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
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = socialIdentities.listSocialIdentities(tenantId);
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
        SocialIdentityDTO dto;
        dto.tenantId = tenantId;
        dto.customerId = CustomerId(data.getString("customerId"));
        dto.provider = data.getString("provider");
        dto.providerUserId = data.getString("providerUserId");
        dto.providerEmail = data.getString("providerEmail");
        dto.displayName = data.getString("displayName");
        dto.accessToken = data.getString("accessToken");
        dto.refreshToken = data.getString("refreshToken");
        dto.tokenExpiresAt = j.getInteger("tokenExpiresAt");
        dto.profileData = data.getString("profileData");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = socialIdentities.linkSocialIdentity(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Social identity linked").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = SocialIdentityId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Social Identity ID").set("status", "error").set("statusCode", 400);

        auto e = socialIdentities.getSocialIdentity(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Social identity not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = SocialIdentityId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Social Identity ID").set("status", "error").set("statusCode", 400);

        auto result = socialIdentities.unlinkSocialIdentity(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Social identity unlinked").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = SocialIdentityId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Social Identity ID").set("status", "error").set("statusCode", 400);

        auto result = socialIdentities.deleteSocialIdentity(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Social identity deleted").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 404);
    }
}
