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
class MemoryAccessPolicyRepository : TenantRepository!(AccessPolicy, AccessPolicyId), AccessPolicyRepository {

  size_t countByBucket(BucketId bucketId) {
    return findByBucket(bucketId).length;
  }
  AccessPolicy[] filterByBucket(AccessPolicy[] policies, BucketId bucketId) {
    return policies.filter!(e => e.bucketId == bucketId).array;
  }
  AccessPolicy[] findByBucket(BucketId bucketId) {
    return findAll().filter!(e => e.bucketId == bucketId).array;
  }
  void removeByBucket(BucketId bucketId) {
    foreach (e; findByBucket(bucketId))
      remove(e);
  }

}
