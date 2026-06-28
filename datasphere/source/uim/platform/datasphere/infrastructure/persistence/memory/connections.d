/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.connection;

// import uim.platform.datasphere.domain.entities.connection;
// import uim.platform.datasphere.domain.ports.repositories.connections;


 
import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class MemoryConnectionRepository : TenantRepository!(Connection, ConnectionId), ConnectionRepository {

// #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, ConnectionId id) {
    return findBySpace(tenantId, spaceId).any!(c => c.id == id);
  }

  Connection findById(TenantId tenantId, SpaceId spaceId, ConnectionId id) {
    foreach (c; findBySpace(tenantId, spaceId)) {
      if (c.id == id)
        return c;
    }
    return Connection.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, ConnectionId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById
  
  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  Connection[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(find(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(c => remove(c));
  }
  // #endregion BySpace

  Connection[] findByType(TenantId tenantId, SpaceId spaceId, ConnectionType type) {
    return findBySpace(tenantId, spaceId).filter!(c => c.type == type).array;
  }

  void save(TenantId tenantId, Connection c) {
    store[c.spaceId] ~= c;
  }

  void update(TenantId tenantId, Connection c) {
    if (c.spaceId in store) {
      foreach (existing; store[c.spaceId]) {
        if (existing.id == c.id) {
          existing = c;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, ConnectionId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(c => c.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
