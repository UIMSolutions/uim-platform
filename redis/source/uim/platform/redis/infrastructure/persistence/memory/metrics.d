/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.memory.metrics;

import uim.platform.redis;
import std.algorithm : filter, sort;
import std.array : array;

// mixin(ShowModule!());

@safe:

class MemoryMetricRepository
    : TentRepository!(Metric, MetricId)
    , MetricRepository
{
    override Metric[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByTenant(tenantId).filter!(e => e.instanceId == instanceId).array;
    }

    override Metric[] findByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to) {
        return findByTenant(tenantId)
            .filter!(e => e.instanceId == instanceId && e.timestamp_ >= from && e.timestamp_ <= to)
            .array;
    }

    override Metric findLatestByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        auto results = findByInstance(tenantId, instanceId);
        if (results.length == 0) return Metric.init;
        Metric latest = results[0];
        foreach (m; results[1..$])
            if (m.timestamp_ > latest.timestamp_) latest = m;
        return latest;
    }
}
