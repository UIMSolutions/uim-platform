/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.configuration;

// import uim.platform.job_scheduling.application.usecases.manage.configurations;

import uim.platform.job_scheduling;

// mixin(ShowModule!());

@safe:

class ConfigurationController : ManageHttpController {
    private ManageConfigurationsUseCase usecase;

    this(ManageConfigurationsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/scheduler/configuration", &handleGet);
        router.put("/api/v1/scheduler/configuration", &handleUpdate);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto config = usecase.getConfiguration(tenantId);

        auto resp = Json.emptyObject
            .set("defaultRetries", config.defaultRetries)
            .set("defaultRetryDelayMs", config.defaultRetryDelayMs)
            .set("maxRunDurationMs", config.maxRunDurationMs)
            .set("enableAsyncMode", config.enableAsyncMode)
            .set("enableAlertNotifications", config.enableAlertNotifications);

        return successResponse("Configuration retrieved", "Configuration retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateConfigurationRequest r;
        r.tenantId = tenantId;
        r.defaultRetries = data.getInteger("defaultRetries", 3);
        r.defaultRetryDelayMs = data.getLong("defaultRetryDelayMs", 30000);
        r.maxRunDurationMs = data.getLong("maxRunDurationMs", 600000);
        r.enableAsyncMode = data.getBoolean("enableAsyncMode", true);
        r.enableAlertNotifications = data.getBoolean("enableAlertNotifications", false);

        auto result = usecase.updateConfiguration(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto resp = Json.emptyObject.set("id", result.id);

        return successResponse("Configuration updated", "Configuration updated", 200, resp);
    }
}
