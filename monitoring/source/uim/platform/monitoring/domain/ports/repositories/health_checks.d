/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.health_checks;

// import uim.platform.monitoring.domain.entities.health_check;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - health check configuration persistence.
interface HealthCheckRepository : ITenantRepository!(HealthCheck, HealthCheckId) {

  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId);
  HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId);

  size_t countByType(TenantId tenantId, CheckType checkType);
  HealthCheck[] findByType(TenantId tenantId, CheckType checkType);
  void removeByType(TenantId tenantId, CheckType checkType);
  
}
