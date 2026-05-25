/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.app_build;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class AppBuildController : ManageController {
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
        auto precheck = super.listHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = precheck.tenantId;

        auto items = usecase.listAppBuilds(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("message", "App builds retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = precheck.tenantId;
        auto j = req.json;

        AppBuildDTO dto;
        dto.appBuildId = AppBuildId(j.getString("id"));
        dto.tenantId = tenantId;
        dto.applicationId = ApplicationId(j.getString("applicationId"));
        dto.name = j.getString("name");
        dto.description = j.getString("description");
        dto.buildTarget = j.getString("buildTarget");
        dto.version_ = j.getString("version");
        dto.buildConfig = j.getString("buildConfig");
        dto.signingConfig = j.getString("signingConfig");
        dto.createdBy = UserId(j.getString("createdBy"));

        auto result = usecase.createAppBuild(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);
            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "App build created");

            return resp.set("status", "success").set("statusCode", 201);
        } else {
            return Json.emptyObject.set("error", result.message).set("status", "error").set("statusCode", 400);
        }
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = AppBuildId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid App Build ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto e = usecase.getAppBuild(tenantId, id);
        if (e.isNull) {
            return Json.emptyObject
                .set("error", "App build not found")
                .set("status", "error")
                .set("statusCode", 404);
        }
        return e.toJson()
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = AppBuildId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid App Build ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto data = precheck.data;

        AppBuildDTO dto;
        dto.appBuildId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateAppBuild(dto);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 404);
        }
        return Json.emptyObject
            .set("id", result.id)
            .set("message", "App build updated")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = precheck.tenantId;
        auto path = req.requestURI.to!string;
        auto id = AppBuildId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid App Build ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto result = usecase.deleteAppBuild(tenantId, id);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 404);
        }
        return Json.emptyObject
            .set("message", "App build deleted")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
