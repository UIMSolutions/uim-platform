/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.site_policy;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class SitePolicyController : ManageController {
    private ManageSitePoliciesUseCase sitePolicies;

    this(ManageSitePoliciesUseCase sitePolicies) {
        this.sitePolicies = sitePolicies;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/customer-identity/policies", &handleList);
        router.get("/api/v1/customer-identity/policies/*", &handleGet);
        router.post("/api/v1/customer-identity/policies", &handleCreate);
        router.put("/api/v1/customer-identity/policies/*", &handleUpdate);
        router.delete_("/api/v1/customer-identity/policies/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto items = sitePolicies.listSitePolicies(tenantId);
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
        auto j = req.json;

        SitePolicyDTO dto;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.policyType = data.getString("policyType");
        dto.passwordMinLength = j.getInteger("passwordMinLength");
        dto.passwordComplexity = data.getString("passwordComplexity");
        dto.passwordRequirements = data.getString("passwordRequirements");
        dto.sessionTimeoutSeconds = j.getInteger("sessionTimeoutSeconds");
        dto.mfaRequired = j.getBoolean("mfaRequired");
        dto.mfaMethod = data.getString("mfaMethod");
        dto.captchaEnabled = j.getBoolean("captchaEnabled");
        dto.socialLoginEnabled = j.getBoolean("socialLoginEnabled");
        dto.progressiveProfilingEnabled = j.getBoolean("progressiveProfilingEnabled");
        dto.maxLoginAttempts = j.getInteger("maxLoginAttempts");
        dto.lockoutDurationSeconds = j.getInteger("lockoutDurationSeconds");
        dto.emailVerificationRequired = j.getBoolean("emailVerificationRequired");
        dto.version_ = data.getString("version");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = sitePolicies.createSitePolicy(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Site policy created").set("status", "success").set("statusCode", 201);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = SitePolicyId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Site Policy ID").set("status", "error").set("statusCode", 400);

        auto e = sitePolicies.getSitePolicy(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Site policy not found").set("status", "error").set("statusCode", 404);

        return e.toJson().set("status", "success").set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = SitePolicyId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Site Policy ID").set("status", "error").set("statusCode", 400);

        auto j = req.json;
        SitePolicyDTO dto;
        dto.sitePolicyId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.passwordMinLength = j.getInteger("passwordMinLength");
        dto.sessionTimeoutSeconds = j.getInteger("sessionTimeoutSeconds");
        dto.mfaRequired = j.getBoolean("mfaRequired");
        dto.captchaEnabled = j.getBoolean("captchaEnabled");
        dto.socialLoginEnabled = j.getBoolean("socialLoginEnabled");
        dto.maxLoginAttempts = j.getInteger("maxLoginAttempts");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = sitePolicies.updateSitePolicy(dto);
        if (result.success)
            return Json.emptyObject.set("id", result.id).set("message", "Site policy updated").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = SitePolicyId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid Site Policy ID").set("status", "error").set("statusCode", 400);

        auto result = sitePolicies.deleteSitePolicy(tenantId, id);
        if (result.success)
            return Json.emptyObject.set("message", "Site policy deleted").set("status", "success").set("statusCode", 200);
        return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 404);
    }
}
