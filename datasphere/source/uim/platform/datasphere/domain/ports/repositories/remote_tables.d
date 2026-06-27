/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.remote_tables;

// import uim.platform.datasphere.domain.entities.remote_table;
import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
interface RemoteTableRepository : ITentRepository!(RemoteTable, RemoteTableId) {

  bool existsById(TenantId tenantId, SpaceId spaceId, RemoteTableId id);  
  RemoteTable findById(TenantId tenantId, SpaceId spaceId, RemoteTableId id);
  void removeById(TenantId tenantId, SpaceId spaceId, RemoteTableId id);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  RemoteTable[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId);
  RemoteTable[] findByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId);
  void removeByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId);
  
}
