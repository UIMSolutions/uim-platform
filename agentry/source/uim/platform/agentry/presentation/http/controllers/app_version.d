/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.http.controllers.app_version;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class AppVersionController : PlatformController {
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

    protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto items = usecase.listAppVersions(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "App version list retrieved successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AppVersionId(extractIdFromPath(path));
            auto e = usecase.getAppVersion(tenantId, id);
            if (e.isNull) { writeError(res, 404, "App version not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            AppVersionDTO dto;
            dto.appVersionId = AppVersionId(j.getString("id"));
            dto.mobileApplicationId = MobileApplicationId(j.getString("mobileApplicationId"));
            dto.definitionId = AppDefinitionId(j.getString("definitionId"));
            dto.tenantId = tenantId;
            dto.versionNumber = j.getString("versionNumber");
            dto.releaseNotes = j.getString("releaseNotes");
            dto.artifactUrl = j.getString("artifactUrl");
            dto.checksum = j.getString("checksum");
            dto.minOsVersion = j.getString("minOsVersion");
            dto.changeLog = j.getString("changeLog");
            dto.isMandatoryUpdate = j.getBool("isMandatoryUpdate");

            auto result = usecase.createAppVersion(dto);
            if (!result.success) { writeError(res, 400, result.error); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "App version created successfully");
            res.writeJsonBody(resp, 201);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            AppVersionDTO dto;
            dto.appVersionId = AppVersionId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.releaseNotes = j.getString("releaseNotes");
            dto.artifactUrl = j.getString("artifactUrl");
            dto.changeLog = j.getString("changeLog");

            auto result = usecase.updateAppVersion(dto);
            if (!result.success) { writeError(res, 404, result.error); return; }

            auto resp = Json.emptyObject
                .set("id", result.id)
                .set("message", "App version updated successfully");
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AppVersionId(extractIdFromPath(path));
            auto result = usecase.deleteAppVersion(tenantId, id);
            if (!result.success) { writeError(res, 404, result.error); return; }
            res.writeJsonBody(Json.emptyObject.set("message", "App version deleted successfully"), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
