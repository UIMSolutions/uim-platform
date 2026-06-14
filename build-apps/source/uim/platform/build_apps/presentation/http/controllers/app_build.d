/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.app_build;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class AppBuildController : ManageHttpController {
    private ManageAppBuildsUseCase usecase;

    this(ManageAppBuildsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/app-builds", &handleList);
        router.get("/api/v1/build-apps/app-builds/*", &handleGet);
        router.post("/api/v1/build-apps/app-builds", &handleCreate);
        router.put("/api/v1/build-apps/app-builds/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/app-builds/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = precheck.tenantId;
        auto applicationIdRaw = req.query.get("applicationId", "");
        AppBuild[] items;
        if (applicationIdRaw.length > 0)
            items = usecase.listAppBuilds(tenantId, ApplicationId(applicationIdRaw));
        else
            items = usecase.listAppBuilds(tenantId);

        auto list = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", list)
            .set("message", "App builds retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        AppBuildDTO dto;
        dto.buildId = AppBuildId(precheck.id);
        dto.tenantId = tenantId;
        dto.applicationId = ApplicationId(data.getString("applicationId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.buildTarget = data.getString("buildTarget");
        dto.version_ = data.getString("version");
        dto.buildConfig = data.getString("buildConfig");
        dto.signingConfig = data.getString("signingConfig");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createAppBuild(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("App build created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AppBuildId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid App Build ID", 400);

        auto e = usecase.getAppBuild(tenantId, id);
        if (e.isNull)
            return errorResponse("App build not found", 404);

        return successResponse("App build retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AppBuildId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid App Build ID", 400);

        auto data = precheck.data;
        AppBuildDTO dto;
        dto.buildId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.buildTarget = data.getString("buildTarget");
        dto.version_ = data.getString("version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateAppBuild(dto);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("App build updated successfully", "Updated", 200, Json.emptyObject.set("id", result
                .id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = AppBuildId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid App Build ID", 400);

        auto result = usecase.deleteAppBuild(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("App build deleted successfully", "Deleted", 200, Json.emptyObject);
    }
}
