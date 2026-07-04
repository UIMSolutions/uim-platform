/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.presentation.http.controllers.application;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

class ApplicationController : ManageHttpController {
    private ManageApplicationsUseCase usecase;

    this(ManageApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

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
        auto list = items.map!(e => e.toJson()).array.toJson;
        return successResponse("Applications retrieved successfully", "OK", 200, Json.emptyObject
                .set("count", items.length)
                .set("resources", list));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ApplicationId(precheck.id);
        auto e = usecase.getApplication(tenantId, id);
        if (e.isNull)
            return errorResponse("Application not found", 404);

        return successResponse("Application retrieved successfully", "OK", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

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
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ApplicationDTO dto;
        dto.applicationId = ApplicationId(precheck.id);
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.status = data.getString("status");
        dto.logoUrl = data.getString("logoUrl");
        dto.homepageUrl = data.getString("homepageUrl");
        dto.multiTenantEnabled = data.getBoolean("multiTenantEnabled");
        dto.riskBasedAuthEnabled = data.getBoolean("riskBasedAuthEnabled");

        auto result = usecase.updateApplication(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ApplicationId(precheck.id);
        auto result = usecase.deleteApplication(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Application deleted successfully", "Deleted", 200, responseData);
    }
}
