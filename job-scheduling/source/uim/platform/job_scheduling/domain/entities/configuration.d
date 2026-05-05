/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.configuration;

// import uim.platform.job_scheduling.domain.types;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:
struct Configuration {
    mixin TenantEntity!ConfigurationId;

    int defaultRetries;
    long defaultRetryDelayMs;
    long maxRunDurationMs;
    bool enableAsyncMode;
    bool enableAlertNotifications;
    
    Json toJson() const {
        return entityToJson
            .set("defaultRetries", defaultRetries)
            .set("defaultRetryDelayMs", defaultRetryDelayMs)
            .set("maxRunDurationMs", maxRunDurationMs)
            .set("enableAsyncMode", enableAsyncMode)
            .set("enableAlertNotifications", enableAlertNotifications);
    }
}
