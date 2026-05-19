/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.http.controllers.configuration;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ConfigurationController : ManageController {
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
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto items = configurations.listConfigurations(tenantId);
        return Json.emptyObject
            .set("count", items.length)
            .set("resources", items.map!(e => e.toJson()).array.toJson)
            .set("message", "Configurations retrieved successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return Json.emptyObject.set("error", "Invalid configuration ID").set("statusCode", 400);

        auto e = configurations.getConfiguration(tenantId, id);
        if (e.isNull)
            return Json.emptyObject.set("error", "Configuration not found").set("statusCode", 404);

        return e.toJson().set("message", "Configuration retrieved successfully").set("status", "success").set("statusCode", 200);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto data = precheck["data"];

        ConfigurationDTO dto;
        dto.configurationId         = ConfigurationId(data.getString("configurationId", ""));
        dto.tenantId                = tenantId;
        dto.instanceId              = ServiceInstanceId(data.getString("instanceId", ""));
        dto.timeout_                = data.getLong("timeout", 300);
        dto.maxConnections          = data.getLong("maxConnections", 100);
        dto.tlsEnabled              = data.getBool("tlsEnabled", true);
        dto.maxMemoryMb             = data.getLong("maxMemoryMb", 0);
        dto.notifyKeyspaceEvents    = data.getBool("notifyKeyspaceEvents", false);
        dto.activeVersion           = data.getString("activeVersion", "");
        dto.createdBy               = UserId(data.getString("createdBy", ""));

        auto result = configurations.createConfiguration(dto);
        if (result.failure)
            return Json.emptyObject.set("error", result.error).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Configuration created successfully")
            .set("status", "success")
            .set("statusCode", 201);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto data = precheck["data"];

        ConfigurationDTO dto;
        dto.configurationId      = ConfigurationId(extractIdFromPath(req.requestURI.to!string));
        dto.tenantId             = tenantId;
        dto.timeout_             = data.getLong("timeout", 0);
        dto.maxConnections       = data.getLong("maxConnections", 0);
        dto.tlsEnabled           = data.getBool("tlsEnabled", false);
        dto.maxMemoryMb          = data.getLong("maxMemoryMb", 0);
        dto.notifyKeyspaceEvents = data.getBool("notifyKeyspaceEvents", false);
        dto.activeVersion        = data.getString("activeVersion", "");
        dto.updatedBy            = UserId(data.getString("updatedBy", ""));

        auto result = configurations.updateConfiguration(dto);
        if (result.failure)
            return Json.emptyObject.set("error", result.error).set("statusCode", 400);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Configuration updated successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (!precheck.success)
            return Json.emptyObject.set("error", precheck.error);

        auto tenantId = TenantId(precheck.gString("tenantId"));
        auto id = ConfigurationId(extractIdFromPath(req.requestURI.to!string));

        auto result = configurations.deleteConfiguration(tenantId, id);
        if (result.failure)
            return Json.emptyObject.set("error", result.error).set("statusCode", 404);

        return Json.emptyObject
            .set("id", result.id)
            .set("message", "Configuration deleted successfully")
            .set("status", "success")
            .set("statusCode", 200);
    }
}
