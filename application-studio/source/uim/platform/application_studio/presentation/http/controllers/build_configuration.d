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
    private ManageBuildConfigurationsUseCase usecase;

    this(ManageBuildConfigurationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/application-studio/build-configurations", &handleList);
        router.get("/api/v1/application-studio/build-configurations/*", &handleGet);
        router.post("/api/v1/application-studio/build-configurations", &handleCreate);
        router.put("/api/v1/application-studio/build-configurations/*", &handleUpdate);
        router.delete_("/api/v1/application-studio/build-configurations/*", &handleDelete);
    }

    protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            
            auto items = usecase.listBuildConfigurations(tenantId);
            auto jarr = items.map!(e => e.toJson()).array.toJson;

            auto resp = Json.emptyObject
                .set("count", items.length)
                .set("resources", jarr);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BuildConfigurationId(extractIdFromPath(path));

            auto e = usecase.getBuildConfiguration(tenantId, id);
            if (e.isNull) {
                writeError(res, 404, "Build configuration not found");
                return;
            }
            res.writeJsonBody(e.toJson(), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto j = req.json;
            BuildConfigurationDTO dto;
            dto.id = j.getString("id");
            dto.tenantId = tenantId;
            dto.projectId = j.getString("projectId");
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.buildCommand = j.getString("buildCommand");
            dto.deployCommand = j.getString("deployCommand");
            dto.artifactPath = j.getString("artifactPath");
            dto.mtaDescriptor = j.getString("mtaDescriptor");
            dto.createdBy = UserId(j.getString("createdBy"));

            auto result = usecase.createBuildConfiguration(dto);
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

    protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto j = req.json;

            BuildConfigurationDTO dto;
            dto.id = BuildConfigurationId(extractIdFromPath(path));
            dto.tenantId = tenantId;
            dto.name = j.getString("name");
            dto.description = j.getString("description");
            dto.buildCommand = j.getString("buildCommand");
            dto.deployCommand = j.getString("deployCommand");
            dto.updatedBy = UserId(j.getString("updatedBy"));

            auto result = usecase.updateBuildConfiguration(dto);
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

    protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.getTenantId;
            auto path = req.requestURI.to!string;
            auto id = BuildConfigurationId(extractIdFromPath(path));

            auto result = usecase.deleteBuildConfiguration(tenantId, id);
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
