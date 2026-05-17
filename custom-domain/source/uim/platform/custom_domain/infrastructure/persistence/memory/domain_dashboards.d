/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.infrastructure.persistence.memory.domain_dashboards;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class MemoryDomainDashboardRepository : TenantRepository!(DomainDashboard, DomainDashboardId), DomainDashboardRepository {

    DomainDashboard get(TenantId tenantId) {
        auto dashboards = findByTenant(tenantId);
        if (dashboards.length > 0)
            return dashboards[0];
            
        return DomainDashboard.init;
    }

    size_t countByMetricType(TenantId tenantId, DashboardMetricType metricType) {
        return findByMetricType(tenantId, metricType).length;
    }

    DomainDashboard[] filterByMetricType(DomainDashboard[] dashboards, DashboardMetricType metricType) {
        return dashboards.filter!(d => d.metrics.canFind!metricType).array;
    }

    DomainDashboard[] findByMetricType(TenantId tenantId, DashboardMetricType metricType) {
        return filterByMetricType(findByTenant(tenantId), metricType);
    }

    void removeByMetricType(TenantId tenantId, DashboardMetricType metricType) {
        findByMetricType(tenantId, metricType).each!(d => remove(d));
    }

}
