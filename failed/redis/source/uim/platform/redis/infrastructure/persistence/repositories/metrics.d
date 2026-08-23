/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.repositories.metrics;

import uim.platform.redis;
import std.algorithm : filter, sort;
import std.array : array;

mixin(ShowModule!());

@safe:

class MetricRepository
    : TenantRepository!(Metric, MetricId)
    , MetricRepository
{

    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }

    Metric[] filterByInstance(Metric[] records, ServiceInstanceId instanceId) {
        return records.filter!(e => e.instanceId == instanceId).array;
    }

     Metric[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return filterByInstance(findByTenant(tenantId), instanceId).sort!((a, b) => a.timestamp_ < b.timestamp_).array;
    }

    void removeByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        findByInstance(tenantId, instanceId).each!(entity => remove(entity));
    }

    size_t countByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to) {
        return findByInstanceAndTimeRange(tenantId, instanceId, from, to).length;
    }   

    Metric[] filterByInstanceAndTimeRange(Metric[] records, ServiceInstanceId instanceId, long from, long to) {
        return filterByInstance(records, instanceId).filter!(e => e.timestamp_ >= from && e.timestamp_ <= to).array;
    }

     Metric[] findByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to) {
        return filterByInstanceAndTimeRange(findByTenant(tenantId), instanceId, from, to);
    }

    void removeByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to) {
        findByInstanceAndTimeRange(tenantId, instanceId, from, to).each!(entity => remove(entity));
    }

     Metric findLatestByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        auto results = findByInstance(tenantId, instanceId);
        if (results.length == 0) return Metric.init;
        Metric latest = results[0];
        foreach (m; results[1..$])
            if (m.timestamp_ > latest.timestamp_) latest = m;
        return latest;
    }
}
