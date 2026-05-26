/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.app_version;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class AppVersionController : ManageController {
    private ManageAppVersionsUseCase usecase;

    this(ManageAppVersionsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/agentry/app-versions", &handleList);
        router.get("/api/v1/agentry/app-versions/*", &handleGet);
        router.post("/api/v1/agentry/app-versions", &handleCreate);
        router.put("/api/v1/agentry/app-versions/*", &handleUpdate);
        router.delete_("/api/v1/agentry/app-versions/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto versions = usecase.listAppVersions(tenantId);
        auto jsVersions = versions.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", versions.length)
            .set("resources", jsVersions);

        return successResponse("App version list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AppVersionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid app version ID", 400);

        auto e = usecase.getAppVersion(tenantId, id);
        if (e.isNull)
            return errorResponse("App version not found", 404);

        auto responseData = e.toJson();
        return successResponse("App version retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        AppVersionDTO dto;
        dto.appVersionId = AppVersionId(data.getString("id"));
        dto.mobileApplicationId = MobileApplicationId(data.getString("mobileApplicationId"));
        dto.definitionId = AppDefinitionId(data.getString("definitionId"));
        dto.tenantId = tenantId;
        dto.versionNumber = data.getString("versionNumber");
        dto.releaseNotes = data.getString("releaseNotes");
        dto.artifactUrl = data.getString("artifactUrl");
        dto.checksum = data.getString("checksum");
        dto.minOsVersion = data.getString("minOsVersion");
        dto.changeLog = data.getString("changeLog");
        dto.isMandatoryUpdate = data.getBool("isMandatoryUpdate");

        auto result = usecase.createAppVersion(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("App version created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = AppVersionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid app version ID", 400);

        auto data = precheck.data;
        AppVersionDTO dto;
        dto.versionId = id;
        dto.tenantId = tenantId;
        dto.releaseNotes = data.getString("releaseNotes");
        dto.artifactUrl = data.getString("artifactUrl");
        dto.changeLog = data.getString("changeLog");

        auto result = usecase.updateAppVersion(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", id);
        return successResponse("App version updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = AppVersionId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid app version ID", 400);

        auto result = usecase.deleteAppVersion(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("App version deleted successfully", "Deleted", 200, responseData);
    }
}
