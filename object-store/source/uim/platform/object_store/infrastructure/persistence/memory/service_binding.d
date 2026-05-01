/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.service_binding;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.service_binding;
// import uim.platform.object_store.domain.ports.repositories.service_binding;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

  size_t countByBucket(BucketId bucketId) {
    return findByBucket(bucketId).length;
  }
  ServiceBinding[] findByBucket(BucketId bucketId) {
    return findAll().filter!(e => e.bucketId == bucketId).array;
  }
  void removeByBucket(BucketId bucketId) {
    foreach (e; findByBucket(bucketId))
      e.remove();
  }

}
