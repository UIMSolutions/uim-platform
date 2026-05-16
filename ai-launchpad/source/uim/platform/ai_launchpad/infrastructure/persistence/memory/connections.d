/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.connections;

// import uim.platform.ai_launchpad.domain.ports.repositories.connections;
// import uim.platform.ai_launchpad.domain.entities.connection : Connection;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryConnectionRepository : TenantRepository!(Connection, ConnectionId), IConnectionRepository {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  Connection[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return filterByWorkspace(findByTenant(tenantId), workspaceId);
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    foreach (c; findByWorkspace(tenantId, workspaceId)) {
      remove(c);
    }
  }

}
