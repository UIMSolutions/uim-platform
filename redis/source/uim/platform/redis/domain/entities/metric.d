/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.entities.metric;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

struct Metric {
    mixin TenantEntity!(MetricId);

    ServiceInstanceId instanceId;
    long timestamp_;
    long memoryUsedMb;
    long memoryTotalMb;
    long connectedClients;
    long commandsPerSecond;
    double hitRate;
    long evictedKeys;
    long expiredKeys;
    long totalCommandsProcessed;
    double cpuUsagePercent;
    long networkInputKbs;
    long networkOutputKbs;

    Json toJson() const {
        return Json.emptyObject
            .set("id",                      id.value)
            .set("tenantId",                tenantId.value)
            .set("instanceId",              instanceId.value)
            .set("timestamp",               timestamp_)
            .set("memoryUsedMb",            memoryUsedMb)
            .set("memoryTotalMb",           memoryTotalMb)
            .set("connectedClients",        connectedClients)
            .set("commandsPerSecond",       commandsPerSecond)
            .set("hitRate",                 hitRate)
            .set("evictedKeys",             evictedKeys)
            .set("expiredKeys",             expiredKeys)
            .set("totalCommandsProcessed",  totalCommandsProcessed)
            .set("cpuUsagePercent",         cpuUsagePercent)
            .set("networkInputKbs",         networkInputKbs)
            .set("networkOutputKbs",        networkOutputKbs)
            .set("createdAt",               createdAt)
            .set("createdBy",               createdBy.value);
    }
}
