/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.dashboards;

import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation.domain.entities.dashboard;

interface DashboardRepository {
    Dashboard findById(DashboardId id);
    Dashboard[] findByTenant(TenantId tenantId);
    Dashboard[] findByType(TenantId tenantId, DashboardType type);
    void save(Dashboard d);
    void update(Dashboard d);
    void remove(DashboardId id);
    long countByTenant(TenantId tenantId);
}
