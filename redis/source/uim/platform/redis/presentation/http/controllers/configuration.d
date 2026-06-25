/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.configuration;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class ConfigurationController : ManageHttpController {
    private ManageConfigurationsUseCase configurations;

    this(ManageConfigurationsUseCase configurations) {
        this.configurations = configurations;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/redis/configurations",   &handleList);
        router.get("/api/v1/redis/configurations/*", &handleGet);
        router.post("/api/v1/redis/configurations",  &handleCreate);
        router.put("/api/v1/redis/configurations/*", &handleUpdate);
        router.delete_("/api/v1/redis/configurations/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto items = configurations.listConfigurations(tenantId);
        return successResponse("Configurations retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson));

    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ConfigurationId(precheck.id);
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid configuration ID").set("statusCode", 400);

        auto e = configurations.getConfiguration(tenantId, id);
        if (e.isNull)
            return errorResponse("Configuration not found", 404);

        return successResponse("Configuration retrieved successfully", "Retrieved", 200, e.toJson());
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;
        ConfigurationDTO dto;
        dto.configurationId         = ConfigurationId(data.getString("configurationId", ""));
        dto.tenantId                = tenantId;
        dto.instanceId              = ServiceInstanceId(data.getString("instanceId", ""));
        dto.timeout_                = data.getLong("timeout", 300);
        dto.maxConnections          = data.getLong("maxConnections", 100);
        dto.tlsEnabled              = data.getBoolean("tlsEnabled", true);
        dto.maxMemoryMb             = data.getLong("maxMemoryMb", 0);
        dto.notifyKeyspaceEvents    = data.getBoolean("notifyKeyspaceEvents", false);
        dto.activeVersion           = data.getString("activeVersion", "");
        dto.createdBy               = UserId(data.getString("createdBy", ""));

        auto result = configurations.createConfiguration(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Configuration created successfully", "Created", 201, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid configuration ID", 400);

        auto data = precheck.data;
        ConfigurationDTO dto;
        dto.configurationId      = id;
        dto.tenantId             = tenantId;
        dto.timeout_             = data.getLong("timeout", 0);
        dto.maxConnections       = data.getLong("maxConnections", 0);
        dto.tlsEnabled           = data.getBoolean("tlsEnabled", false);
        dto.maxMemoryMb          = data.getLong("maxMemoryMb", 0);
        dto.notifyKeyspaceEvents = data.getBoolean("notifyKeyspaceEvents", false);
        dto.activeVersion        = data.getString("activeVersion", "");
        dto.updatedBy            = UserId(data.getString("updatedBy", ""));

        auto result = configurations.updateConfiguration(dto);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("Configuration updated successfully", "Updated", 200, Json.emptyObject
            .set("id", result.id));
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ConfigurationId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid configuration ID", 400);

        auto result = configurations.deleteConfiguration(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("Configuration deleted successfully", "Deleted", 200, Json.emptyObject
            .set("id", result.id));
    }
}
