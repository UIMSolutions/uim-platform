/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.build_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class BuildConfigurationController : PlatformController {
    private ManageBuildConfigurationsUseCase uc;

    this(ManageBuildConfigurationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/application-studio/build-configurations", &handleList);
        router.get("/api/v1/application-studio/build-configurations/*", &handleGet);
        router.post("/api/v1/application-studio/build-configurations", &handleCreate);
        router.put("/api/v1/application-studio/build-configurations/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/build-configurations/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => e.buildConfigurationToJson()).array;
            
            auto resp = Json.emptyObject
              .set("count", items.length)
              .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto e = uc.getById(BuildConfigurationId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Build configuration not found"); return; }
            res.writeJsonBody(e.buildConfigurationToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            BuildConfigurationDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.projectId = j.getString("projectId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.buildCommand = j.getString("buildCommand");
            dto.deployCommand = j.getString("deployCommand");
            dto.artifactPath = j.getString("artifactPath");
            dto.mtaDescriptor = j.getString("mtaDescriptor");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Build configuration created");

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
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            BuildConfigurationDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.buildCommand = j.getString("buildCommand");
            dto.deployCommand = j.getString("deployCommand");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Build configuration updated");

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
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(BuildConfigurationId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Build configuration deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
