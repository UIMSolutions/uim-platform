/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.health_check;

import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.domain.entities.health_check;
import uim.platform.monitoring.domain.ports.repositories.health_checks;

// import std.algorithm : filter;
// import std.array : array;

class MemoryHealthCheckRepository : HealthCheckRepository {
  private HealthCheck[HealthCheckId] store;

  HealthCheck findById(HealthCheckId id) {
    if (auto p = id in store)
      return *p;
    return HealthCheck.init;
  }

  HealthCheck[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.resourceId == resourceId).array;
  }

  HealthCheck[] findByType(TenantId tenantId, CheckType checkType) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.checkType == checkType).array;
  }

  void save(HealthCheck check) {
    store[check.id] = check;
  }

  void update(HealthCheck check) {
    store[check.id] = check;
  }

  void remove(HealthCheckId id) {
    store.remove(id);
  }
}
