/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.health_checks;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.ports.repositories.health_checks;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryHealthCheckRepository : HealthCheckRepository {
  private HealthCheck[HealthCheckId] store;

  bool existsById(HealthCheckId id) {
    return (id in store) ? true : false;
  }

  HealthCheck findById(HealthCheckId id) {
    return existsById(id) ? store[id] : HealthCheck.init;
  }

  HealthCheck[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId).array;
  }

  HealthCheck[] findByType(TenantId tenantId, CheckType checkType) {
    return findByTenant(tenantId).filter!(e => e.checkType == checkType).array;
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
