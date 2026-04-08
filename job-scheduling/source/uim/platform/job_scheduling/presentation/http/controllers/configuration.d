/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.presentation.http.controllers.configuration;

import uim.platform.job_scheduling.application.usecases.manage.configurations;
import uim.platform.job_scheduling.application.dto;
import uim.platform.job_scheduling.presentation.http.json_utils;

import uim.platform.job_scheduling;

class ConfigurationController : SAPController {
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
            auto config = uc.get_(tenantId);

            auto resp = Json.emptyObject;
            resp["defaultRetries"] = Json(cast(long) config.defaultRetries);
            resp["defaultRetryDelayMs"] = Json(config.defaultRetryDelayMs);
            resp["maxRunDurationMs"] = Json(config.maxRunDurationMs);
            resp["enableAsyncMode"] = Json(config.enableAsyncMode);
            resp["enableAlertNotifications"] = Json(config.enableAlertNotifications);
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
            r.defaultRetries = jsonInt(j, "defaultRetries", 3);
            r.defaultRetryDelayMs = jsonLong(j, "defaultRetryDelayMs", 30000);
            r.maxRunDurationMs = jsonLong(j, "maxRunDurationMs", 600000);
            r.enableAsyncMode = jsonBool(j, "enableAsyncMode", true);
            r.enableAlertNotifications = jsonBool(j, "enableAlertNotifications", false);

            auto result = uc.update(r);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Configuration updated");
                res.writeJsonBody(resp, 200);
            } ) {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}
