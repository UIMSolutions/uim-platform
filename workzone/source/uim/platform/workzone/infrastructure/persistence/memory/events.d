/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.events;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.event;
import uim.platform.workzone.domain.ports.repositories.events;

// import std.algorithm : filter;
// import std.array : array;

class MemoryEventRepository : TenantRepository!(Event, EventId), EventRepository {

  // #region ByWorkspace
  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  Event[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(e => e.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).each!(e => remove(e));
  }
  // #endregion ByWorkspace

  // #region ByOrganizer
  size_t countByOrganizer(TenantId tenantId, UserId organizerId) {
    return findByOrganizer(tenantId, organizerId).length;
  }

  Event[] findByOrganizer(TenantId tenantId, UserId organizerId) {
    return findByTenant(tenantId).filter!(e => e.organizerId == organizerId).array;
  }

  void removeByOrganizer(TenantId tenantId, UserId organizerId) {
    return findByOrganizer(tenantId, organizerId).each!(e => remove(e));
  }
  // #endregion ByOrganizer

}
