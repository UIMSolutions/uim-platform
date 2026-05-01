/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.cors_rule;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.cors_rule;
// import uim.platform.object_store.domain.ports.repositories.cors_rule;
// 
// import std.algorithm : filter;
// import std.array : array;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryCorsRuleRepository : CorsRuleRepository {
  private CorsRule[CorsRuleId] store;

  bool existsById(CorsRuleId id) {
    return (id in store) ? true : false;
  }

  CorsRule findById(CorsRuleId id) {
    return existsById(id) ? store[id] : CorsRule.init;
  }

  CorsRule[] findByBucket(BucketId bucketId) {
    return findAll()r!(e => e.bucketId == bucketId).array;
  }

  void save(CorsRule entity) {
    store[entity.id] = entity;
  }

  void update(CorsRule entity) {
    store[entity.id] = entity;
  }

  void remove(CorsRuleId id) {
    store.removeById(id);
  }
}
