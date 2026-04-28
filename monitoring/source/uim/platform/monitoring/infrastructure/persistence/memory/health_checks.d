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
class MemoryHealthCheckRepository : TenantRepository!(HealthCheck, HealthCheckId), HealthCheckRepository {

  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByResource(tenantId, resourceId).length;
  }
  HealthCheck[] filterByResource(HealthCheck[] checks, MonitoredResourceId resourceId) {
    return checks.filter!(e => e.resourceId == resourceId).array;
  }
  HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId).array;
  }
  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    findByResource(tenantId, resourceId).each!(e => remove(e));
  }

  size_t countByType(TenantId tenantId, CheckType checkType) {
    return findByType(tenantId, checkType).length;
  }
  HealthCheck[] filterByType(HealthCheck[] checks, CheckType checkType) {
    return checks.filter!(e => e.checkType == checkType).array;
  }
  HealthCheck[] findByType(TenantId tenantId, CheckType checkType) {
    return findByTenant(tenantId).filter!(e => e.checkType == checkType).array;
  }
  void removeByType(TenantId tenantId, CheckType checkType) {
    findByType(tenantId, checkType).each!(e => remove(e));
  }

}
