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
class MemoryHealthCheckResultRepository : TenantRepository!(HealthCheckResult, HealthCheckResultId), HealthCheckResultRepository {

  HealthCheckResult findLatestByCheck(TenantId tenantId, HealthCheckId checkId) {
    HealthCheckResult latest;
    foreach (r; findByCheck(tenantId, checkId)) {
      if (latest.isNull || r.executedAt > latest.executedAt)
        latest = r;
    }
    return latest;
  }

  HealthCheckResult[] findByTenant(TenantId tenantId) {
    return findAll().filter!(r => r.tenantId == tenantId).array;
  }

  size_t countByCheck(TenantId tenantId, HealthCheckId checkId) {
    return findByCheck(tenantId, checkId).length;
  }

  HealthCheckResult[] filterByCheck(HealthCheckResult[] results, HealthCheckId checkId) {
    return results.filter!(r => r.checkId == checkId).array;
  }

  HealthCheckResult[] findByCheck(TenantId tenantId, HealthCheckId checkId) {
    return findByTenant(tenantId).filter!(r => r.checkId == checkId).array;
  }

  void removeByCheck(TenantId tenantId, HealthCheckId checkId) {
    findByCheck(tenantId, checkId).each!(r => remove(r));
  }

  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByResource(tenantId, resourceId).length;
  }

  HealthCheckResult[] filterByResource(HealthCheckResult[] results, MonitoredResourceId resourceId) {
    return results.filter!(r => r.resourceId == resourceId).array;
  }

  HealthCheckResult[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(r => r.resourceId == resourceId).array;
  }

  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    findByResource(tenantId, resourceId).each!(r => remove(r));
  }

  size_t countInTimeRange(TenantId tenantId, HealthCheckId checkId, long startTime, long endTime) {
    return findInTimeRange(tenantId, checkId, startTime, endTime).length;
  }
  HealthCheckResult[] filterInTimeRange(HealthCheckResult[] results, HealthCheckId checkId, long startTime, long endTime) {
    return results.filter!(r => r.checkId == checkId && r.executedAt >= startTime && r.executedAt <= endTime).array;
  }
  HealthCheckResult[] findInTimeRange(TenantId tenantId, HealthCheckId checkId,
    long startTime, long endTime) {
    return findByCheck(tenantId, checkId).filter!(r => r.executedAt >= startTime && r.executedAt <= endTime)
      .array;
  }
  void removeInTimeRange(TenantId tenantId, HealthCheckId checkId, long startTime, long endTime) {
    findInTimeRange(tenantId, checkId, startTime, endTime).each!(r => remove(r));
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = findAll().filter!(r => !(r.tenantId == tenantId && r.executedAt < beforeTimestamp))
      .array;
  }
}
