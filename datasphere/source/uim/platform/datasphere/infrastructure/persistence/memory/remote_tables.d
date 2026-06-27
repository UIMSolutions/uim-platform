/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.remote_tables;

// import uim.platform.datasphere.domain.entities.remote_table;
// import uim.platform.datasphere.domain.ports.repositories.remote_tables;

import uim.platform.datasphere;

// mixin(ShowModule!());

@safe:
class MemoryRemoteTableRepository : TenantRepository!(RemoteTable, RemoteTableId), RemoteTableRepository {

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

  RemoteTable[] findByConnection(TenantId tenantId, SpaceId spaceId, ConnectionId connId) {
    return findByTenant(tenantId).filter!(rt => rt.spaceId == spaceId && rt.connectionId == connId)
      .array;
  }

}
