/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.tls_configuration;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class TlsConfigurationController : ManageController {
    private ManageTlsConfigurationsUseCase usecase;

    this(ManageTlsConfigurationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/tls-configurations", &handleList);
        router.get("/api/v1/custom-domain/tls-configurations/*", &handleGet);
        router.post("/api/v1/custom-domain/tls-configurations", &handleCreate);
        router.put("/api/v1/custom-domain/tls-configurations/*", &handleUpdate);
        router.delete_("/api/v1/custom-domain/tls-configurations/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto configs = usecase.listTlsConfigurations(tenantId);

        auto jarr = Json.emptyArray;
        foreach (c; configs) {
            jarr ~= Json.emptyObject
                .set("id", c.id)
                .set("name", c.name)
                .set("description", c.description)
                .set("minProtocolVersion", c.minProtocolVersion.to!string)
                .set("maxProtocolVersion", c.maxProtocolVersion.to!string)
                .set("http2Enabled", c.http2Enabled)
                .set("hstsEnabled", c.hstsEnabled)
                .set("hstsMaxAge", c.hstsMaxAge)
                .set("hstsIncludeSubDomains", c.hstsIncludeSubDomains)
                .set("createdBy", c.createdBy)
                .set("createdAt", c.createdAt);
        }

        return successResponse("TLS configurations retrieved successfully", 200,
            Json.emptyObject.set("count", configs.length).set("resources", jarr));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;
        auto id = TlsConfigurationId(data.getString("id"));
        if (id.isNull)
            return errorResponse("TLS Configuration ID is required", 400);

        CreateTlsConfigurationRequest r;
        r.tenantId = tenantId;
        r.tlsConfigurationId = id;
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.minProtocolVersion = data.getString("minProtocolVersion");
        r.maxProtocolVersion = data.getString("maxProtocolVersion");
        r.http2Enabled = data.getBoolean("http2Enabled");
        r.hstsEnabled = data.getBoolean("hstsEnabled");
        r.hstsMaxAge = jsonLong(data, "hstsMaxAge");
        r.hstsIncludeSubDomains = data.getBoolean("hstsIncludeSubDomains");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createTlsConfiguration(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        return successResponse("TLS configuration created successfully", 201,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto id = TlsConfigurationId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return errorResponse("Invalid TLS Configuration ID", 400);

        auto c = usecase.getTlsConfiguration(tenantId, id);
        if (c.isNull)
            return errorResponse("TLS configuration not found", 404);

        auto response = Json.emptyObject
            .set("entity", "TlsConfiguration")
            .set("id", c.id)
            .set("name", c.name)
            .set("description", c.description)
            .set("minProtocolVersion", c.minProtocolVersion.to!string)
            .set("maxProtocolVersion", c.maxProtocolVersion.to!string)
            .set("http2Enabled", c.http2Enabled)
            .set("hstsEnabled", c.hstsEnabled)
            .set("hstsMaxAge", c.hstsMaxAge)
            .set("hstsIncludeSubDomains", c.hstsIncludeSubDomains)
            .set("createdBy", c.createdBy)
            .set("updatedBy", c.updatedBy)
            .set("createdAt", c.createdAt)
            .set("updatedAt", c.updatedAt);

        return successResponse("TLS configuration retrieved successfully", 200,
            Json.emptyObject.set("resource", response));
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto data = precheck.data;

        UpdateTlsConfigurationRequest r;
        r.tenantId = tenantId;
        r.tlsConfigurationId = TlsConfigurationId(extractIdFromPath(req.requestURI.to!string));
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.minProtocolVersion = data.getString("minProtocolVersion");
        r.maxProtocolVersion = data.getString("maxProtocolVersion");
        r.http2Enabled = data.getBoolean("http2Enabled");
        r.hstsEnabled = data.getBoolean("hstsEnabled");
        r.hstsMaxAge = data.getLong("hstsMaxAge");
        r.hstsIncludeSubDomains = data.getBoolean("hstsIncludeSubDomains");
        r.updatedBy = UserId(data.getString("updatedBy"));

        auto result = usecase.updateTlsConfiguration(r);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("TLS configuration updated successfully", 200,
            Json.emptyObject.set("id", result.id));

    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto id = TlsConfigurationId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return errorResponse("Invalid TLS Configuration ID", 400);

        auto result = usecase.deleteTlsConfiguration(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 404);

        return successResponse("TLS configuration deleted successfully", 200,
            Json.emptyObject.set("id", result.id));
    }

}
