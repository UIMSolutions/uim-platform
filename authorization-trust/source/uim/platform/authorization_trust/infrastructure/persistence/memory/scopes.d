/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.infrastructure.persistence.memory.scopes;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class MemoryScopeRepository : ScopeRepository {
  private ScopeEntity[ScopeId] store;

  bool existsById(ScopeId id) {
    return (id in store) !is null;
  }

  ScopeEntity findById(ScopeId id) {
    return existsById(id) ? store[id] : ScopeEntity.init;
  }

  bool existsByName(string name) {
    return findByName(name).id.length > 0;
  }

  ScopeEntity findByName(string name) {
    foreach (s; store.values)
      if (s.name == name)
        return s;
    return ScopeEntity.init;
  }

  ScopeEntity[] findAll() {
    return store.values.dup;
  }

  ScopeEntity[] findByAppId(string appId) {
    return store.values.filter!(s => s.appId == appId).array;
  }

  void save(ScopeEntity scope_) {
    store[scope_.id] = scope_;
  }

  void update(ScopeEntity scope_) {
    store[scope_.id] = scope_;
  }

  void remove(ScopeId id) {
    store.remove(id);
  }

  size_t count() {
    return store.length;
  }
}
