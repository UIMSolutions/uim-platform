/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.dashboard;

// import uim.platform.logging.domain.entities.dashboard;
// import uim.platform.logging.domain.ports.repositories.dashboards;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryDashboardRepository : DashboardRepository {
  private Dashboard[DashboardId] store;

  Dashboard findById(DashboardId id) {
    if (auto p = id in store)
      return *p;
    return Dashboard.init;
  }

  Dashboard[] findByTenant(TenantId tenantId) {
    Dashboard[] result;
    foreach (d; store)
      if (d.tenantId == tenantId)
        result ~= d;
    return result;
  }

  Dashboard findDefault(TenantId tenantId) {
    foreach (d; store)
      if (d.tenantId == tenantId && d.isDefault)
        return d;
    return Dashboard.init;
  }

  void save(Dashboard d) {
    store[d.id] = d;
  }

  void update(Dashboard d) {
    store[d.id] = d;
  }

  void remove(DashboardId id) {
    store.remove(id);
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count;
    foreach (d; store)
      if (d.tenantId == tenantId)
        count++;
    return count;
  }
}
