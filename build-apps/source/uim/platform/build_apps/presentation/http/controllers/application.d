/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.application;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ApplicationController : ManageController {
    private ManageApplicationsUseCase usecase;

    this(ManageApplicationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/build-apps/applications", &handleList);
        router.get("/api/v1/build-apps/applications/*", &handleGet);
        router.post("/api/v1/build-apps/applications", &handleCreate);
        router.put("/api/v1/build-apps/applications/*", &handleUpdate);
        router.delete_("/api/v1/build-apps/applications/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);

        auto items = usecase.listApplications(tenantId);
        auto jarr = items.map!(e => e.toJson()).array.toJson;

        return Json.emptyObject
            .set("count", items.length)
            .set("resources", jarr)
            .set("message", "Applications retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];
        auto id = ApplicationId(data.getString("id"));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid Application ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        ApplicationDTO dto;
        dto.applicationId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.appType = data.getString("appType");
        dto.version_ = data.getString("version");
        dto.iconUrl = data.getString("iconUrl");
        dto.themeConfig = data.getString("themeConfig");
        dto.globalVariables = data.getString("globalVariables");
        dto.defaultLanguage = data.getString("defaultLanguage");
        dto.supportedLanguages = data.getString("supportedLanguages");
        dto.owner = data.getString("owner");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createApplication(dto);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 400);
        }
        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Application created")
            .set("status", "success")
            .set("statusCode", 201);

    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = ApplicationId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid Application ID")
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto e = usecase.getApplication(tenantId, id);
        if (e.isNull) {
            return Json.emptyObject
                .set("error", "Application not found")
                .set("status", "error")
                .set("statusCode", 404);
        }
        return Json.emptyObject
            .set("data", e.toJson())
            .set("message", "Application retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error);
        }

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto id = ApplicationId(extractIdFromPath(path));
        if (id.isNull) {
            return Json.emptyObject
                .set("error", "Invalid Application ID")
                .set("status", "error")
                .set("statusCode", 400);
        }
        auto data = precheck["data"];

        ApplicationDTO dto;
        dto.applicationId = id;
        dto.tenantId = tenantId;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.version_ = data.getString("version");
        dto.iconUrl = data.getString("iconUrl");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateApplication(dto);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 400);
        }
        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Application updated")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) {
            return Json.emptyObject.set("error", precheck.error)
                .set("status", "error")
                .set("statusCode", 400);
        }

        auto tenantId = getTenantId(precheck);
        auto path = req.requestURI.to!string;
        auto applicationId = ApplicationId(extractIdFromPath(path));

        auto result = usecase.deleteApplication(tenantId, applicationId);
        if (result.hasError) {
            return Json.emptyObject
                .set("error", result.message)
                .set("status", "error")
                .set("statusCode", 404);
        }

        return Json.emptyObject
            .set("message", "Application deleted")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
