/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.roles;

import uim.platform.authorization_trust;
import std.algorithm : filter;
import std.array : array;

mixin(ShowModule!());

@safe:

class MemoryRoleRepository : RoleRepository {
  private RoleEntity[RoleId] store;

  bool existsById(RoleId id) {
    return (id in store) !is null;
  }

  RoleEntity findById(RoleId id) {
    return existsById(id) ? store[id] : RoleEntity.init;
  }

  bool existsByName(string name, string appId) {
    return findByName(name, appId).id.length > 0;
  }

  RoleEntity findByName(string name, string appId) {
    foreach (r; store.values)
      if (r.name == name && r.appId == appId)
        return r;
    return RoleEntity.init;
  }

  RoleEntity[] findAll() {
    return store.values.dup;
  }

  RoleEntity[] findByAppId(string appId) {
    return store.values.filter!(r => r.appId == appId).array;
  }

  void save(RoleEntity role) {
    store[role.id] = role;
  }

  void update(RoleEntity role) {
    store[role.id] = role;
  }

  void remove(RoleId id) {
    store.remove(id);
  }

  size_t count() {
    return store.length;
  }
}
