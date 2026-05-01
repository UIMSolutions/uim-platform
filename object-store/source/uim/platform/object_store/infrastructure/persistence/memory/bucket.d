/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.bucket;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.bucket;
// import uim.platform.object_store.domain.ports.repositories.bucket;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryBucketRepository : TenantRepository!(Bucket, BucketId), BucketRepository {

  bool existsByName(TenantId tenantId, string name) {
    foreach (e; findAll())
      if (e.tenantId == tenantId && e.name == name)
        return true;
    return false;
  }
  
  Bucket findByName(TenantId tenantId, string name) {
    foreach (e; findAll())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return Bucket.init;
  }

  void removeByName(TenantId tenantId, string name) {
    findByName(tenantId, name).remove();
  }
}
