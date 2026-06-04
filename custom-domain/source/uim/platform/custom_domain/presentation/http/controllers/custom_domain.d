/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.custom_domain;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class CustomDomainController : ManageHttpController {
    private ManageCustomDomainsUseCase usecase;

    this(ManageCustomDomainsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/domains", &handleList);
        router.get("/api/v1/custom-domain/domains/*", &handleGet);
        router.post("/api/v1/custom-domain/domains", &handleCreate);
        router.put("/api/v1/custom-domain/domains/*", &handleUpdate);
        router.post("/api/v1/custom-domain/domains/*/activate", &handleActivate);
        router.post("/api/v1/custom-domain/domains/*/deactivate", &handleDeactivate);
        router.delete_("/api/v1/custom-domain/domains/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto domains = usecase.listDomains(tenantId);
        auto jarr = domains.map!(d => Json.emptyObject
                .set("id", d.id)
                .set("domainName", d.domainName)
                .set("status", d.status.to!string)
                .set("organizationId", d.organizationId)
                .set("spaceId", d.spaceId)
                .set("activeCertificateId", d.activeCertificateId)
                .set("isShared", d.isShared)
                .set("clientAuthEnabled", d.clientAuthEnabled)
                .set("createdBy", d.createdBy)
                .set("createdAt", d.createdAt)).array.toJson;

        return successResponse("Custom domains retrieved successfully", 200,
            Json.emptyObject.set("count", domains.length).set("resources", jarr));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        auto id = CustomDomainId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Custom Domain ID", 400);

        CreateCustomDomainRequest r;
        r.tenantId = tenantId;
        r.customDomainId = id;
        r.domainName = data.getString("domainName");
        r.organizationId = data.getString("organizationId");
        r.spaceId = data.getString("spaceId");
        r.environment = data.getString("environment");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDomain(r);
        if (result.hasError) {
            return errorResponse(result.message, 400);
        }

        return successResponse("Custom domain created", 201,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req); // Assuming ManageController.getHandler for pre-checks
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto path = precheck.path;

        // Check for /activate or /deactivate suffix — skip
        if (path.length > 9 && path[$ - 9 .. $] == "/activate")
            return errorResponse("Use the /activate endpoint to activate custom domains", 400); // Should be a 405 Method Not Allowed, but 400 is acceptable
        if (path.length > 11 && path[$ - 11 .. $] == "/deactivate")
            return errorResponse("Use the /deactivate endpoint to deactivate custom domains", 400); // Should be a 405 Method Not Allowed, but 400 is acceptable

        // Extract ID from path, ensuring no suffix is present
        const idStr = precheck.id;
        auto id = CustomDomainId(idStr);
        if (id.isNull) {
            return errorResponse("Invalid Custom Domain ID", 400);
        }

        auto d = usecase.getDomain(tenantId, id);
        if (d.isNull) {
            return errorResponse("Custom domain not found", 404);
        }

        return successResponse("Custom domain retrieved successfully", 200,
                    Json.emptyObject
                    .set("entity", "CustomDomain")
                    .set("id", d.id)
                    .set("domainName", d.domainName)
                    .set("status", d.status.to!string)
                    .set("environment", d.environment.to!string)
                    .set("organizationId", d.organizationId)
                    .set("spaceId", d.spaceId)
                    .set("activeCertificateId", d.activeCertificateId)
                    .set("tlsConfigurationId", d.tlsConfigurationId)
                    .set("isShared", d.isShared)
                    .set("sharedWithOrgs", d.sharedWithOrgs)
                    .set("clientAuthEnabled", d.clientAuthEnabled)
                    .set("createdBy", d.createdBy)
                    .set("updatedBy", d.updatedBy)
                    .set("createdAt", d.createdAt)
                    .set("updatedAt", d.updatedAt));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req); // Assuming ManageController.updateHandler for pre-checks
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CustomDomainId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Custom Domain ID", 400);

        auto data = precheck.data;
        UpdateCustomDomainRequest r;
        r.customDomainId = id;
        r.tenantId = tenantId;
        r.activeCertificateId = data.getString("activeCertificateId");
        r.tlsConfigurationId = data.getString("tlsConfigurationId");
        r.isShared = data.getBoolean("isShared");
        r.sharedWithOrgs = data.getString("sharedWithOrgs");
        r.clientAuthEnabled = data.getBoolean("clientAuthEnabled");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateDomain(r);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Custom domain updated", 200,
            Json.emptyObject.set("id", result.id));
    }

    protected Json activateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req); // Reuse getHandler for pre-checks
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        if (tenantId.isNull)
            return errorResponse("Tenant ID is required", 400);

        auto path = precheck.path;
        // Path: /api/v1/custom-domain/domains/{id}/activate
        // Extract ID: strip "/activate" suffix, then extract last segment
        enum ACTIVATE_SUFFIX_LEN = "/activate".length;
        auto stripped = path[0 .. $ - ACTIVATE_SUFFIX_LEN]; // remove "/activate"
        auto id = CustomDomainId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid Custom Domain ID", 400);

        auto result = usecase.activateDomain(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Custom domain activated", 200, Json.emptyObject.set("id", result.id));
    }

    protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto resp = activateHandler(req);
            res.writeJsonBody(resp, resp.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected Json deactivateHandler(HTTPServerRequest req) {
        auto precheck = super.postHandler(req); // Reuse postHandler for pre-checks
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        if (tenantId.isNull)
            return errorResponse("Tenant ID is required", 400);

        auto path = precheck.path;
        enum DEACTIVATE_SUFFIX_LEN = "/deactivate".length;
        auto stripped = path[0 .. $ - DEACTIVATE_SUFFIX_LEN]; // remove "/deactivate"
        auto id = CustomDomainId(extractIdFromPath(stripped));
        if (id.isNull)
            return errorResponse("Invalid Custom Domain ID", 400);

        auto result = usecase.deactivateDomain(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Custom domain deactivated", 200, Json.emptyObject.set("id", result.id));
    }

    protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto response = deactivateHandler(req);
            res.writeJsonBody(response, response.code);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req); // Assuming ManageController.deleteHandler for pre-checks
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = CustomDomainId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid Custom Domain ID", 400);

        auto result = usecase.deleteDomain(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Custom domain deleted", 200,
            Json.emptyObject.set("id", result.id));
    }
}
