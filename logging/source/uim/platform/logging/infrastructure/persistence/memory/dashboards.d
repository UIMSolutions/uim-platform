/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.dashboards;

// import uim.platform.logging.domain.entities.dashboard;
// import uim.platform.logging.domain.ports.repositories.dashboards;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryDashboardRepository : TenantRepository!(Dashboard, DashboardId), DashboardRepository {

  bool existsDefault(TenantId tenantId) {
    return findByTenant(tenantId).any!(d => d.isDefault);
  }
  Dashboard findDefault(TenantId tenantId) {
    foreach (d; findByTenant(tenantId))
      if (d.isDefault)
        return d;
    return Dashboard.init;
  }

}
