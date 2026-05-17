/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.role_collections;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class MemoryRoleCollectionRepository : RoleCollectionRepository {
  private RoleCollectionEntity[RoleCollectionId] store;

  bool existsById(RoleCollectionId id) {
    return (id in store) !is null;
  }

  RoleCollectionEntity findById(RoleCollectionId id) {
    return existsById(id) ? store[id] : RoleCollectionEntity.init;
  }

  bool existsByName(string name) {
    return findByName(name).id.length > 0;
  }

  RoleCollectionEntity findByName(string name) {
    foreach (rc; store.values)
      if (rc.name == name)
        return rc;
    return RoleCollectionEntity.init;
  }

  RoleCollectionEntity[] findByTenant(tenantId) {
    return store.values.dup;
  }

  void save(RoleCollectionEntity rc) {
    store[rc.id] = rc;
  }

  void update(RoleCollectionEntity rc) {
    store[rc.id] = rc;
  }

  void remove(RoleCollectionId id) {
    store.remove(id);
  }

  size_t count() {
    return store.length;
  }
}
