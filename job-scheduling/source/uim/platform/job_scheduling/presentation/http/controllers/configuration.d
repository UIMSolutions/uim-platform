/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.configuration;

// import uim.platform.job_scheduling.application.usecases.manage.configurations;
// import uim.platform.job_scheduling.application.dto;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

class ConfigurationController : PlatformController {
    private ManageConfigurationsUseCase uc;

    this(ManageConfigurationsUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        
        router.get("/api/v1/scheduler/configuration", &handleGet);
        router.put("/api/v1/scheduler/configuration", &handleUpdate);
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            TenantId tenantId = req.getTenantId;
            auto config = uc.getById(tenantId);

            auto resp = Json.emptyObject
                .set("defaultRetries", config.defaultRetries)
                .set("defaultRetryDelayMs", config.defaultRetryDelayMs)
                .set("maxRunDurationMs", config.maxRunDurationMs)
                .set("enableAsyncMode", config.enableAsyncMode)
                .set("enableAlertNotifications", config.enableAlertNotifications);

            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;

            UpdateConfigurationRequest r;
            r.tenantId = req.getTenantId;
            r.defaultRetries = j.getInteger("defaultRetries", 3);
            r.defaultRetryDelayMs = jsonLong(j, "defaultRetryDelayMs", 30000);
            r.maxRunDurationMs = jsonLong(j, "maxRunDurationMs", 600000);
            r.enableAsyncMode = j.getBoolean("enableAsyncMode", true);
            r.enableAlertNotifications = j.getBoolean("enableAlertNotifications", false);

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject
                    .set("id", result.id)
                    .set("message", "Configuration updated");
                
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
