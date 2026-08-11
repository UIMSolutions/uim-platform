/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.connections;

// import uim.platform.datasphere.domain.entities.connection;
// import uim.platform.datasphere.domain.ports.repositories.connections;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:
class ConnectionRepository : TenantRepository!(Connection, ConnectionId), IConnectionRepository {

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
    return filterBySpace(findByTenant(tenantId), spaceId);
  }

  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(c => remove(c));
  }
  // #endregion BySpace

  size_t countByType(TenantId tenantId, SpaceId spaceId, ConnectionType type) {
    return findByType(tenantId, spaceId, type).length;
  }

  Connection[] filterByType(Connection[] connections, ConnectionType type) {
    return connections.filter!(c => c.type == type).array;
  }

  Connection[] findByType(TenantId tenantId, SpaceId spaceId, ConnectionType type) {
    return filterByType(findBySpace(tenantId, spaceId), type);
  }

  void removeByType(TenantId tenantId, SpaceId spaceId, ConnectionType type) {
    findByType(tenantId, spaceId, type).each!(c => remove(c));
  }

}
