/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.usecases.connections;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
interface IManageConnectionsUseCase { 

  CommandResult createConnection(CreateConnectionRequest r);

  Connection getConnection(TenantId tenantId, ConnectionId id);

  Connection[] listConnections(TenantId tenantId, WorkspaceId workspaceId);

  Connection[] listConnections(TenantId tenantId);

  CommandResult patchConnection(PatchConnectionRequest r);

  CommandResult deleteConnection(TenantId tenantId, ConnectionId id);
  
}
