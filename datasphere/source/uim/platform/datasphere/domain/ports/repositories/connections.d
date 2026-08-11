/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.connections;

// import uim.platform.datasphere.domain.entities.connection;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IConnectionRepository : ITenantRepository!(Connection, ConnectionId) {

  Connection findById(TenantId tenantId, SpaceId spaceId, ConnectionId id);
  Connection[] findBySpace(TenantId tenantId, SpaceId spaceId);
  Connection[] findByType(TenantId tenantId, SpaceId spaceId, ConnectionType type);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);

}
