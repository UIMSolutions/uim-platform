/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.application;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ApplicationController : ManageController {
    private ManageApplicationsUseCase usecase;

    this(ManageApplicationsUseCase usecase) { this.usecase = usecase; }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/ias/applications", &handleList);
        router.get("/api/v1/ias/applications/*", &handleGet);
        router.post("/api/v1/ias/applications", &handleCreate);
        router.put("/api/v1/ias/applications/*", &handleUpdate);
        router.delete_("/api/v1/ias/applications/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            auto items = usecase.listApplications(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            res.writeJsonBody(Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Applications retrieved successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = Applicationprecheck.id);
            auto e = usecase.getApplication(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Application not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            ApplicationDTO dto;
            dto.applicationId = ApplicationId(precheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.protocol = data.getString("protocol");
            dto.clientId = data.getString("clientId");
            dto.authScheme = data.getString("authScheme");
            dto.logoUrl = data.getString("logoUrl");
            dto.homepageUrl = data.getString("homepageUrl");
            dto.multiTenantEnabled = data.getBoolean("multiTenantEnabled");
            dto.riskBasedAuthEnabled = data.getBoolean("riskBasedAuthEnabled");

            auto result = usecase.createApplication(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Application created successfully"), 201);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            ApplicationDTO dto;
            dto.applicationId = Applicationprecheck.id);
            dto.tenantId = tenantId;
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.status = data.getString("status");
            dto.logoUrl = data.getString("logoUrl");
            dto.homepageUrl = data.getString("homepageUrl");
            dto.multiTenantEnabled = data.getBoolean("multiTenantEnabled");
            dto.riskBasedAuthEnabled = data.getBoolean("riskBasedAuthEnabled");

            auto result = usecase.updateApplication(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Application updated successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto id = Applicationprecheck.id);
            auto result = usecase.deleteApplication(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Application deleted successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
