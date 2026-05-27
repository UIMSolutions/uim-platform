/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.run_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class RunConfigurationController : ManageController {
    private ManageRunConfigurationsUseCase usecase;

    this(ManageRunConfigurationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/run-configurations", &handleList);
        router.get("/api/v1/application-studio/run-configurations/*", &handleGet);
        router.post("/api/v1/application-studio/run-configurations", &handleCreate);
        router.put("/api/v1/application-studio/run-configurations/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/run-configurations/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

            
            auto items = usecase.listRunConfigurations(tenantId);
            auto list = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr)
                .set("message", "Run configuration list retrieved successfully");

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = RunConfigurationId(precheck.id);

            auto e = usecase.getRunConfiguration(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Run configuration not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto data = precheck.data;
            RunConfigurationDTO dto;
            dto.runConfigurationId = RunConfigurationId(precheck.id);
            dto.tenantId = tenantId;
            dto.projectId = ProjectId(data.getString("projectId"));
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.entryPoint = data.getString("entryPoint");
            dto.arguments = data.getString("arguments");
            dto.environmentVars = data.getString("environmentVars");
            dto.port = data.getString("port");
            dto.debugPort = data.getString("debugPort");
            dto.createdBy = UserId(data.getString("createdBy"));

            auto result = usecase.createRunConfiguration(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Run configuration created");

                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto data = precheck.data;
            RunConfigurationDTO dto;
            dto.tenantId = tenantId;
            dto.runConfigurationId = RunConfigurationId(precheck.id);
            dto.name = data.getString("name");
            dto.description = data.getString("description");
            dto.entryPoint = data.getString("entryPoint");
            dto.arguments = data.getString("arguments");
            dto.updatedBy = UserId(data.getString("updatedBy"));

            auto result = usecase.updateRunConfiguration(dto);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Run configuration updated");

            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = precheck.tenantId;
            auto path = req.requestURI.to!string;
            auto id = RunConfigurationId(precheck.id);
            
            auto result = usecase.deleteRunConfiguration(tenantId, id);
            if (result.hasError)
            return errorResponse(result.message, 400);
                auto resp = Json.emptyObject
                    .set("message", "Run configuration deleted");

                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.message);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
