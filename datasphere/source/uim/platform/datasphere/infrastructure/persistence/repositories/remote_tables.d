/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.remote_tables;

// import uim.platform.datasphere.domain.entities.remote_table;
// import uim.platform.datasphere.domain.ports.repositories.remote_tables;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:
class RemoteTableRepository : TenantRepository!(RemoteTable, RemoteTableId), IRemoteTableRepository {

  // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, RemoteTableId id) {
    return findBySpace(tenantId, spaceId).any!(rt => rt.id == id);
  }

  RemoteTable findById(TenantId tenantId, SpaceId spaceId, RemoteTableId id) {
    foreach (rt; findBySpace(tenantId, spaceId)) {
      if (rt.id == id)
        return rt;
    }
    return RemoteTable.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, RemoteTableId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById
  
  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }

  RemoteTable[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(rt => remove(rt));
  }
  // #endregion BySpace

  size_t countByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId) {
    return findByConnection(tenantId, spaceId, connId).length;
  }

  RemoteTable[] filterByConnection(RemoteTable[] remoteTables, ConnectionId connId) {
    return remoteTables.filter!(rt => rt.connectionId == connId).array;
  }

  RemoteTable[] findByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId) {
    return filterByConnection(findBySpace(tenantId, spaceId), connId);
  }

  void removeByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId) {
    findByConnection(tenantId, spaceId, connId).each!(rt => remove(rt));
  }

}
