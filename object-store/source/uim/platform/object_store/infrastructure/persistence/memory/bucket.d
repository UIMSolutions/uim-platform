/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.bucket;

import uim.platform.object_store.domain.types;
import uim.platform.object_store.domain.entities.bucket;
import uim.platform.object_store.domain.ports.repositories.bucket;

// import std.algorithm : filter;
// import std.array : array;

class MemoryBucketRepository : BucketRepository {
  private Bucket[BucketId] store;

  Bucket findById(BucketId id) {
    if (auto p = id in store)
      return *p;
    return null;
  }

  Bucket findByName(TenantId tenantId, string name) {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return null;
  }

  Bucket[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(Bucket entity) {
    store[entity.id] = entity;
  }

  void update(Bucket entity) {
    store[entity.id] = entity;
  }

  void remove(BucketId id) {
    store.remove(id);
  }
}
