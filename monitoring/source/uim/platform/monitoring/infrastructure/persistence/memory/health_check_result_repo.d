/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.health_check_result_repo;

import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.domain.entities.health_check_result;
import uim.platform.monitoring.domain.ports.repositories.health_check_results;

// import std.algorithm : filter;
// import std.array : array;

class MemoryHealthCheckResultRepository : HealthCheckResultRepository
{
  private HealthCheckResult[] store;

  HealthCheckResult findById(HealthCheckResultId id)
  {
    foreach (ref r; store)
      if (r.id == id)
        return r;
    return HealthCheckResult.init;
  }

  HealthCheckResult[] findByCheck(TenantId tenantId, HealthCheckId checkId)
  {
    return store.filter!(r => r.tenantId == tenantId && r.checkId == checkId).array;
  }

  HealthCheckResult[] findByResource(TenantId tenantId, MonitoredResourceId resourceId)
  {
    return store.filter!(r => r.tenantId == tenantId && r.resourceId == resourceId).array;
  }

  HealthCheckResult findLatestByCheck(TenantId tenantId, HealthCheckId checkId)
  {
    HealthCheckResult latest;
    foreach (ref r; store)
    {
      if (r.tenantId == tenantId && r.checkId == checkId)
      {
        if (latest.id.length == 0 || r.executedAt > latest.executedAt)
          latest = r;
      }
    }
    return latest;
  }

  HealthCheckResult[] findInTimeRange(TenantId tenantId, HealthCheckId checkId,
      long startTime, long endTime)
  {
    return store.filter!(r => r.tenantId == tenantId && r.checkId == checkId
        && r.executedAt >= startTime && r.executedAt <= endTime).array;
  }

  void save(HealthCheckResult result)
  {
    store ~= result;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp)
  {
    store = store.filter!(r => !(r.tenantId == tenantId && r.executedAt < beforeTimestamp)).array;
  }
}
