/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.domain_dashboard;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DomainDashboardController : PlatformController {
    private ManageDomainDashboardsUseCase uc;

    this(ManageDomainDashboardsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/custom-domain/dashboard", &handleGet);
        router.post("/api/v1/custom-domain/dashboard/refresh", &handleRefresh);
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto d = uc.get_(tenantId);

            auto resp = Json.emptyObject;
            resp["id"] = Json(d.id);
            resp["totalDomains"] = Json(d.totalDomains);
            resp["activeDomains"] = Json(d.activeDomains);
            resp["totalCertificates"] = Json(d.totalCertificates);
            resp["activeCertificates"] = Json(d.activeCertificates);
            resp["totalMappings"] = Json(d.totalMappings);
            resp["activeMappings"] = Json(d.activeMappings);
            resp["overallHealth"] = Json(d.overallHealth.to!string);
            resp["lastUpdatedAt"] = Json(d.lastUpdatedAt);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleRefresh(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            RefreshDashboardRequest r;
            r.tenantId = req.getTenantId;

            auto result = uc.refresh(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Dashboard refreshed");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
