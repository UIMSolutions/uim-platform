/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.dashboards;
// import uim.platform.analytics.domain.entities.dashboard;
// import uim.platform.analytics.domain.repositories.dashboard;


import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// In-memory adapter implementing DashboardRepository port.
class MemoryDashboardRepository : TentRepository!(Dashboard, DashboardId), DashboardRepository {

  size_t countByOwner(TenantId tenantId, EntityId ownerId) {
    return findByOwner(tenantId, ownerId).length;
  }

  Dashboard[] filterByOwner(Dashboard[] dashboards, EntityId ownerId) {
    return dashboards.filter!(d => d.ownerId == ownerId).array;
  }

  Dashboard[] findByOwner(TenantId tenantId, EntityId ownerId) {
    return filterByOwner(findByTenant(tenantId), ownerId);
  }

  void removeByOwner(TenantId tenantId, EntityId ownerId) {
    foreach (d; findByOwner(tenantId, ownerId))
      remove(d);
  }

  size_t countByStatus(TenantId tenantId, ArtifactStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Dashboard[] filterByStatus(Dashboard[] dashboards, ArtifactStatus status) {
    return dashboards.filter!(d => d.status == status).array;
  }

  Dashboard[] findByStatus(TenantId tenantId, ArtifactStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ArtifactStatus status) {
    foreach (d; findByStatus(tenantId, status))
      remove(d);
  }
}
