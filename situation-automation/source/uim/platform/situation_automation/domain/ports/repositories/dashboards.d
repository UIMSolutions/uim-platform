/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.dashboards;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.dashboard;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface DashboardRepository : ITenantRepository!(Dashboard, DashboardId) {

    size_t countByType(TenantId tenantId, DashboardType type);
    Dashboard[] findByType(TenantId tenantId, DashboardType type);
    void removeByType(TenantId tenantId, DashboardType type);

}
