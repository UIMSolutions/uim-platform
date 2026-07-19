/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.presentation.http.controllers.build_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class BuildConfigurationController : ManageHttpController {
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

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listBuildConfigurations(tenantId);
        auto list = items.map!(e => e.toJson()).array.toJson;

        auto resp = Json.emptyObject
            .set("count", items.length)
            .set("resources", list);
        return successResponse("Build configuration list retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        BuildConfigurationDTO dto;
        dto.configId = precheck.id;
        dto.tenantId = tenantId;
        dto.projectId = data.getString("projectId");
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.buildCommand = data.getString("buildCommand");
        dto.deployCommand = data.getString("deployCommand");
        dto.artifactPath = data.getString("artifactPath");
        dto.mtaDescriptor = data.getString("mtaDescriptor");
        dto.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createBuildConfiguration(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);
        return successResponse("Build configuration created successfully", "Created", 201, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BuildConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid build configuration ID", "InvalidId", 400);

        auto e = usecase.getBuildConfiguration(tenantId, id);
        if (e.isNull)
            return errorResponse("Build configuration not found", "NotFound", 404);

        Json responseData = e.toJson();
        return successResponse("Build configuration retrieved successfully", "Retrieved", 200, responseData);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BuildConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid build configuration ID", "InvalidId", 400);

        auto data = precheck.data;
        BuildConfigurationDTO dto;
        dto.tenantId = tenantId;
        dto.configId = id;
        dto.name = data.getString("name");
        dto.description = data.getString("description");
        dto.buildCommand = data.getString("buildCommand");
        dto.deployCommand = data.getString("deployCommand");
        dto.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateBuildConfiguration(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Build configuration updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = BuildConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid build configuration ID", "InvalidId", 400);

        auto result = usecase.deleteBuildConfiguration(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Build configuration deleted successfully", "Deleted", 200, responseData);
    }
}
