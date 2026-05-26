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

    override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
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
            auto tenantId = req.getTenantId;
            auto id = ApplicationId(extractIdFromPath(req.requestURI.to!string));
            auto e = usecase.getApplication(tenantId, id);
            if (e.isNull) { writeError(res, 404, "Application not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ApplicationDTO dto;
            dto.applicationId = ApplicationId(j.getString("id"));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.protocol = j.getString("protocol");
            dto.clientId = j.getString("clientId");
            dto.authScheme = j.getString("authScheme");
            dto.logoUrl = j.getString("logoUrl");
            dto.homepageUrl = j.getString("homepageUrl");
            dto.multiTenantEnabled = j.getBool("multiTenantEnabled");
            dto.riskBasedAuthEnabled = j.getBool("riskBasedAuthEnabled");

            auto result = usecase.createApplication(dto);
            if (!result.success) { writeError(res, 400, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Application created successfully"), 201);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            ApplicationDTO dto;
            dto.applicationId = ApplicationId(extractIdFromPath(req.requestURI.to!string));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.status = j.getString("status");
            dto.logoUrl = j.getString("logoUrl");
            dto.homepageUrl = j.getString("homepageUrl");
            dto.multiTenantEnabled = j.getBool("multiTenantEnabled");
            dto.riskBasedAuthEnabled = j.getBool("riskBasedAuthEnabled");

            auto result = usecase.updateApplication(dto);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("id", result.id).set("message", "Application updated successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto id = ApplicationId(extractIdFromPath(req.requestURI.to!string));
            auto result = usecase.deleteApplication(tenantId, id);
            if (!result.success) { writeError(res, 404, result.message); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "Application deleted successfully"), 200);
        } catch (Exception e) { writeError(res, 500, "Internal server error"); }
    }
}
