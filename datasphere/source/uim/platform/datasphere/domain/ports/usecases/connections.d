/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.connections;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:
interface IManageConnectionsUseCase {

  UsecaseResult createConnection(CreateConnectionRequest r);
  Connection getConnection(TenantId tenantId, ConnectionId id, SpaceId spaceId);
  Connection[]  listConnections(TenantId tenantId, SpaceId spaceId);
  UsecaseResult updateConnection(UpdateConnectionRequest r);
  UsecaseResult deleteConnection(TenantId tenantId, ConnectionId id, SpaceId spaceId);

}
