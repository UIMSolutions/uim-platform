/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.health_check_result_repository;

import uim.platform.monitoring.domain.entities.health_check_result;
import uim.platform.monitoring.domain.types;

/// Port: outgoing - health check result persistence.
interface HealthCheckResultRepository
{
  HealthCheckResult findById(HealthCheckResultId id);
  HealthCheckResult[] findByCheck(TenantId tenantId, HealthCheckId checkId);
  HealthCheckResult[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  HealthCheckResult findLatestByCheck(TenantId tenantId, HealthCheckId checkId);
  HealthCheckResult[] findInTimeRange(TenantId tenantId, HealthCheckId checkId,
      long startTime, long endTime);
  void save(HealthCheckResult result);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
