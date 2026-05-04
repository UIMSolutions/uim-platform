/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.health_check_results;

// import uim.platform.monitoring.domain.entities.health_check_result;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - health check result persistence.
interface HealthCheckResultRepository : ITenantRepository!(HealthCheckResult, HealthCheckResultId) {

  HealthCheckResult findLatestByCheck(TenantId tenantId, HealthCheckId checkId);

  size_t countByCheck(TenantId tenantId, HealthCheckId checkId);
  HealthCheckResult[] findByCheck(TenantId tenantId, HealthCheckId checkId);
  void removeByCheck(TenantId tenantId, HealthCheckId checkId);
  
  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId);
  HealthCheckResult[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId);

  size_t countInTimeRange(TenantId tenantId, HealthCheckId checkId, long startTime, long endTime);
  HealthCheckResult[] findInTimeRange(TenantId tenantId, HealthCheckId checkId,
      long startTime, long endTime);
  void removeInTimeRange(TenantId tenantId, HealthCheckId checkId, long startTime, long endTime);

  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
