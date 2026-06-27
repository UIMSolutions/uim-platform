/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.repositories.dashboard;
// import uim.platform.analytics.domain.entities.dashboard;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// Port: outgoing repository interface for Dashboard persistence.
interface DashboardRepository : ITentRepository!(Dashboard, DashboardId) {

  size_t countByOwner(TenantId tenantId, EntityId ownerId);
  Dashboard[] findByOwner(TenantId tenantId, EntityId ownerId);
  void removeByOwner(TenantId tenantId, EntityId ownerId);

  size_t countByStatus(TenantId tenantId, ArtifactStatus status);
  Dashboard[] findByStatus(TenantId tenantId, ArtifactStatus status);
  void removeByStatus(TenantId tenantId, ArtifactStatus status);

}
