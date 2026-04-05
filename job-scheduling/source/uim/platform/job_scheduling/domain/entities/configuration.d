/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.job_scheduling.domain.entities.configuration;

import uim.platform.job_scheduling.domain.types;

struct Configuration {
    ConfigId id;
    TenantId tenantId;
    int defaultRetries;
    long defaultRetryDelayMs;
    long maxRunDurationMs;
    bool enableAsyncMode;
    bool enableAlertNotifications;
    long createdAt;
    long modifiedAt;
}
