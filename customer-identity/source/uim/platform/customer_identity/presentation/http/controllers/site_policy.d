/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.presentation.http.controllers.site_policy;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class SitePolicyController : ManageHttpController {
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
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = sitePolicies.listSitePolicies(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Site policies retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        SitePolicyDTO dto;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.policyType = data.getString("policyType");
        dto.passwordMinLength = data.getInteger("passwordMinLength");
        dto.passwordComplexity = data.getString("passwordComplexity");
        dto.passwordRequirements = data.getString("passwordRequirements");
        dto.sessionTimeoutSeconds = data.getInteger("sessionTimeoutSeconds");
        dto.mfaRequired = data.getBoolean("mfaRequired");
        dto.mfaMethod = data.getString("mfaMethod");
        dto.captchaEnabled = data.getBoolean("captchaEnabled");
        dto.socialLoginEnabled = data.getBoolean("socialLoginEnabled");
        dto.progressiveProfilingEnabled = data.getBoolean("progressiveProfilingEnabled");
        dto.maxLoginAttempts = data.getInteger("maxLoginAttempts");
        dto.lockoutDurationSeconds = data.getInteger("lockoutDurationSeconds");
        dto.emailVerificationRequired = data.getBoolean("emailVerificationRequired");
        dto.version_ = data.getString("version");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = sitePolicies.createSitePolicy(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Site policy created successfully", "Created", 201, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = SitePolicyId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Site Policy ID", 400);

        auto e = sitePolicies.getSitePolicy(tenantId, id);
        if (e.isNull)
            return errorResponse("Site policy not found", 404);

        return successResponse("Site policy retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = SitePolicyId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Site Policy ID", 400);

        auto data = precheck.data;
        SitePolicyDTO dto;
        dto.sitePolicyId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.passwordMinLength = data.getInteger("passwordMinLength");
        dto.sessionTimeoutSeconds = data.getInteger("sessionTimeoutSeconds");
        dto.mfaRequired = data.getBoolean("mfaRequired");
        dto.captchaEnabled = data.getBoolean("captchaEnabled");
        dto.socialLoginEnabled = data.getBoolean("socialLoginEnabled");
        dto.maxLoginAttempts = data.getInteger("maxLoginAttempts");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = sitePolicies.updateSitePolicy(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Site policy updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;
        auto id = SitePolicyId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Site Policy ID", 400);

        auto result = sitePolicies.deleteSitePolicy(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Site policy deleted successfully", "Deleted", 200, responseData);
    }
}
