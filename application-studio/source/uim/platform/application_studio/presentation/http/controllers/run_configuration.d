/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.run_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class RunConfigurationController : PlatformController {
    private ManageRunConfigurationsUseCase uc;

    this(ManageRunConfigurationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/application-studio/run-configurations", &handleList);
        router.get("/api/v1/application-studio/run-configurations/*", &handleGet);
        router.post("/api/v1/application-studio/run-configurations", &handleCreate);
        router.put("/api/v1/application-studio/run-configurations/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/run-configurations/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = items.map!(e => e.runConfigurationToJson()).array;

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
            auto e = uc.getById(RunConfigurationId(id));
            if (e.id.value.length == 0) { writeError(res, 404, "Run configuration not found"); return; }
            res.writeJsonBody(e.runConfigurationToJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            RunConfigurationDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = req.getTenantId;
            dto.projectId = j.getString("projectId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.entryPoint = j.getString("entryPoint");
            dto.arguments = j.getString("arguments");
            dto.environmentVars = j.getString("environmentVars");
            dto.port = j.getString("port");
            dto.debugPort = j.getString("debugPort");
            dto.createdBy = j.getString("createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Run configuration created");

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
            RunConfigurationDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.entryPoint = j.getString("entryPoint");
            dto.arguments = j.getString("arguments");
            dto.updatedBy = j.getString("updatedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("id", result.id)
                  .set("message", "Run configuration updated");

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
            auto result = uc.remove(RunConfigurationId(id));
            if (result.success) {
                auto resp = Json.emptyObject
                  .set("message", "Run configuration deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
