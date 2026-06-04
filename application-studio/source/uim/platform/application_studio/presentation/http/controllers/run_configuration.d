/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.run_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class RunConfigurationController : ManageHttpController {
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
        auto list = items.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("Run configuration list retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = RunConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid run configuration ID", 400);

        auto config = usecase.getRunConfiguration(tenantId, id);
        if (config.isNull)
            return errorResponse("Scan job not found", 404);

        auto responseData = config.toJson();
        return successResponse("Run configuration retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        RunConfigurationDTO dto;
        dto.runConfigurationId = RunConfigurationId(
            precheck.id);
        dto.tenantId = tenantId;
        dto.projectId = ProjectId(
            data.getString("projectId"));
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.entryPoint = data.getString(
            "entryPoint");
        dto.arguments = data.getString("arguments");
        dto.environmentVars = data.getString("environmentVars");
        dto.port = data.getString("port");
        dto.debugPort = data.getString(
            "debugPort");
        dto.createdBy = UserId(
            data.getString("createdBy"));

        auto result = usecase.createRunConfiguration(
            dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Run configuration created successfully", "Created", 201, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = RunConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid run configuration ID", 400);

        auto data = precheck.data;
        RunConfigurationDTO dto;
        dto.tenantId = tenantId;
        dto.runConfigurationId = id;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.entryPoint = data.getString("entryPoint");
        dto.arguments = data.getString("arguments");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateRunConfiguration(
            dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Run configuration updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = RunConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid run configuration ID", 400);

        auto result = usecase.deleteRunConfiguration(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Run configuration deleted successfully", "Deleted", 200, responseData);
    }
}
