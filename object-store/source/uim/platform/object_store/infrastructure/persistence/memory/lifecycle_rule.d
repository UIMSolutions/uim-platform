/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.lifecycle_rule;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.lifecycle_rule;
// import uim.platform.object_store.domain.ports.repositories.lifecycle_rule;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryLifecycleRuleRepository : LifecycleRuleRepository {
  private LifecycleRule[LifecycleRuleId] store;

  bool existsById(LifecycleRuleId id) {
    return (id in store) ? true : false;
  }

  LifecycleRule findById(LifecycleRuleId id) {
    return existsById(id) ? store[id] : LifecycleRule.init;
  }

  LifecycleRule[] findByBucket(BucketId bucketId) {
    return findAll().filter!(e => e.bucketId == bucketId).array;
  }

  void save(LifecycleRule entity) {
    store[entity.id] = entity;
  }

  void update(LifecycleRule entity) {
    store[entity.id] = entity;
  }

  void remove(LifecycleRuleId id) {
    store.remove(id);
  }
}
