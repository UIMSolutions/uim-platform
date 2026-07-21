/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.repositories.dashboards;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryDashboardRepository : TenantRepository!(Dashboard, DashboardId), DashboardRepository {

    // #region ByType
    size_t countByType(TenantId tenantId, DashboardType type) {
        return findByType(tenantId, type).length;
    }
    Dashboard[] filterByType(Dashboard[] dashboards, DashboardType type) {
        return dashboards.filter!(d => d.type == type).array;
    }
    Dashboard[] findByType(TenantId tenantId, DashboardType type) {
        return filterByType(findByTenant(tenantId), type);
    }
    void removeByType(TenantId tenantId, DashboardType type) {
        findByType(tenantId, type).each!(d => remove(d));
    }
    // #endregion ByType

}
