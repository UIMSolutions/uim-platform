/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.repositories.connections;

// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.domain.entities.connection : Connection;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

interface IConnectionRepository : ITenantRepository!(Connection, ConnectionId) {
  
  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  Connection[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);

}
