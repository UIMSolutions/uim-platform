/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.dashboard_repository;

import uim.platform.logging.domain.entities.dashboard;
import uim.platform.logging.domain.types;

interface DashboardRepository {
  Dashboard findById(DashboardId id);
  Dashboard[] findByTenant(TenantId tenantId);
  Dashboard findDefault(TenantId tenantId);
  void save(Dashboard d);
  void update(Dashboard d);
  void remove(DashboardId id);
  long countByTenant(TenantId tenantId);
}
