/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.dashboards;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryDashboardRepository : TenantRepository!(Dashboard, DashboardId), DashboardRepository {

    size_t countByType(TenantId tenantId, DashboardType type) {
        return findByType(tenantId, type).length;
    }
    Dashboard[] findByType(TenantId tenantId, DashboardType type) {
        return findByTenant(tenantId).filter!(d => d.type == type).array;
    }
    void removeByType(TenantId tenantId, DashboardType type) {
        findByType(tenantId, type).each!(d => remove(d.id));
    }

}
