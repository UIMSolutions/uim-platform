/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.presentation.http.controllers.app_build;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class AppBuildController : PlatformController {
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

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = usecase.list(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr)
              .set("message", "App builds retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = AppBuildId(extractIdFromPath(path));
            auto e = usecase.getById(tenantId, id);
            if (e.isNull) { writeError(res, 404, "App build not found"); return; }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            AppBuildDTO dto;
            dto.appBuildId = AppBuildId(j.getString("id"));
            dto.tenantId = req.getTenantId;
            dto.applicationId = ApplicationId(j.getString("applicationId"));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.buildTarget = j.getString("buildTarget");
            dto.version_ = j.getString("version");
            dto.buildConfig = j.getString("buildConfig");
            dto.signingConfig = j.getString("signingConfig");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "App build created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            AppBuildDTO dto;
            dto.appBuildId = AppBuildId(extractIdFromPath(path));
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.version_ = j.getString("version");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "App build updated");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto path = req.requestURI.to!string;
            auto id = AppBuildId(extractIdFromPath(path));
            auto result = usecase.deleteAppBuild(id);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "App build deleted");
                  
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
