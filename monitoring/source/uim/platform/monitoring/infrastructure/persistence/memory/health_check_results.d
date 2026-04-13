/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.health_check_results;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.ports.repositories.health_check_results;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryHealthCheckResultRepository : HealthCheckResultRepository {
  private HealthCheckResult[] store;

  bool existsById(HealthCheckResultId id) {
    return store.any!(r => r.id == id);
  }

  HealthCheckResult findById(HealthCheckResultId id) {
    foreach (r; store)
      if (r.id == id)
        return r;
    return HealthCheckResult.init;
  }

  HealthCheckResult[] findByTenant(TenantId tenantId) {
    return store.filter!(r => r.tenantId == tenantId).array;
  }

  HealthCheckResult[] findByCheck(TenantId tenantId, HealthCheckId checkId) {
    return findByTenant(tenantId).filter!(r => r.checkId == checkId).array;
  }

  HealthCheckResult[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(r => r.resourceId == resourceId).array;
  }

  HealthCheckResult findLatestByCheck(TenantId tenantId, HealthCheckId checkId) {
    HealthCheckResult latest;
    foreach (r; findByCheck(tenantId, checkId)) {
      if (latest.id.isEmpty || r.executedAt > latest.executedAt)
        latest = r;
    }
    return latest;
  }

  HealthCheckResult[] findInTimeRange(TenantId tenantId, HealthCheckId checkId,
      long startTime, long endTime) {
    return findByCheck(tenantId, checkId).filter!(r => r.executedAt >= startTime && r.executedAt <= endTime).array;
  }

  void save(HealthCheckResult result) {
    store ~= result;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(r => !(r.tenantId == tenantId && r.executedAt < beforeTimestamp)).array;
  }
}
