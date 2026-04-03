/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.health_check_repository;

import uim.platform.monitoring.domain.entities.health_check;
import uim.platform.monitoring.domain.types;

/// Port: outgoing - health check configuration persistence.
interface HealthCheckRepository
{
  HealthCheck findById(HealthCheckId id);
  HealthCheck[] findByTenant(TenantId tenantId);
  HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  HealthCheck[] findByType(TenantId tenantId, CheckType checkType);
  void save(HealthCheck check);
  void update(HealthCheck check);
  void remove(HealthCheckId id);
}
