/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.access_policy;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.access_policy;
// import uim.platform.object_store.domain.ports.repositories.access_policy;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryAccessPolicyRepository : AccessPolicyRepository {
  private AccessPolicy[AccessPolicyId] store;

  bool existsById(AccessPolicyId id) {
    return (id in store) ? true : false;
  }

  AccessPolicy findById(AccessPolicyId id) {
    return existsById(id) ? store[id] : AccessPolicy.init;
  }

  AccessPolicy[] findByBucket(BucketId bucketId) {
    return store.byValue().filter!(e => e.bucketId == bucketId).array;
  }

  AccessPolicy[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(AccessPolicy entity) {
    store[entity.id] = entity;
  }

  void update(AccessPolicy entity) {
    store[entity.id] = entity;
  }

  void remove(AccessPolicyId id) {
    store.remove(id);
  }
}
