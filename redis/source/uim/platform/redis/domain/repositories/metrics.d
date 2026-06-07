/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.repositories.metrics;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

interface MetricRepository : ITenantRepository!(Metric, MetricId) {
    Metric[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);
    Metric[] findByInstanceAndTimeRange(TenantId tenantId, ServiceInstanceId instanceId, long from, long to);
    Metric   findLatestByInstance(TenantId tenantId, ServiceInstanceId instanceId);
}
