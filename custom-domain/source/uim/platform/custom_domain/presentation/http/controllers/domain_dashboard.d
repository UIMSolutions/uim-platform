/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.domain_dashboard;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DomainDashboardController : ManageController {
    private ManageDomainDashboardsUseCase usecase;

    this(ManageDomainDashboardsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/dashboard", &handleGet);
        router.post("/api/v1/custom-domain/dashboard/refresh", &handleRefresh);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto d = usecase.getDashboard(tenantId);
        if (d.isNull) 
            return errorResponse("Dashboard data not found for tenant", 404);
        

        return successResponse("Dashboard data retrieved successfully", 200,
            Json.emptyObject
                .set("id", d.id)
                .set("totalDomains", d.totalDomains)
                .set("activeDomains", d.activeDomains)
                .set("totalCertificates", d.totalCertificates)
                .set("activeCertificates", d.activeCertificates)
                .set("totalMappings", d.totalMappings)
                .set("activeMappings", d.activeMappings)
                .set("overallHealth", d.overallHealth.to!string)
                .set("lastUpdatedAt", d.lastUpdatedAt));
    }

    protected Json refreshHandler(HTTPServerRequest req) {
        auto tenantId = req.getTenantId;
        RefreshDashboardRequest r;
        r.tenantId = tenantId;

        auto result = usecase.refreshDashboard(r);
        if (!result.success) 
            return errorResponse("Failed to refresh dashboard", 500);
        

        return successResponse("Dashboard refreshed successfully", 200,
            Json.emptyObject.set("id", result.id));
    }

    protected void handleRefresh(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto resp = refreshHandler(req);
            res.writeJsonBody(resp, resp.statusCode);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
