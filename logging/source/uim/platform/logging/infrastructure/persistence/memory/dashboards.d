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

  bool existsById(DashboardId id) {
    return (id in store) ? true : false;
  }

  Dashboard findById(DashboardId id) {
    return (existsById(id)) ? store[id] : Dashboard.init;
  }

  Dashboard[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(d => d.tenantId == tenantId).array;
  }

  Dashboard findDefault(TenantId tenantId) {
    foreach (d; findByTenant(tenantId))
      if (d.isDefault)
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
    return findByTenant(tenantId).length;
  }
}
