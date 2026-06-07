/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.storage_object;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.storage_object;
// import uim.platform.object_store.domain.ports.repositories.storage_object;

// import std.algorithm : filter, startsWith;

import uim.platform.object_store;

// mixin(ShowModule!());

@safe:
class MemoryStorageObjectRepository : TenantRepository!(StorageObject, StorageObjectId), StorageObjectRepository {

  bool existsByKey(TenantId tenantId, BucketId bucketId, string key) {
    return findByTenant(tenantId).any!(e => e.bucketId == bucketId && e.key == key);
  }

  StorageObject findByKey(TenantId tenantId, BucketId bucketId, string key) {
    foreach (e; findByTenant(tenantId))
      if (e.bucketId == bucketId && e.key == key)
        return e;
    return StorageObject.init;
  }

  size_t countByBucket(TenantId tenantId, BucketId bucketId) {
    return findByBucket(tenantId, bucketId).length;
  }

  StorageObject[] filterByBucket(StorageObject[] objects, BucketId bucketId) {
    return objects.filter!(e => e.bucketId == bucketId).array;
  }

  StorageObject[] findByBucket(TenantId tenantId, BucketId bucketId) {
    return findByTenant(tenantId).filter!(e => e.bucketId == bucketId).array;
  }

  void removeByBucket(TenantId tenantId, BucketId bucketId) {
    foreach (e; findByBucket(tenantId, bucketId))
      remove(e);
  }

  size_t countByPrefix(TenantId tenantId, BucketId bucketId, string prefix) {
    return findByPrefix(tenantId, bucketId, prefix).length;
  }

  StorageObject[] filterByPrefix(StorageObject[] objects, string prefix) {
    return objects.filter!(e => e.key.startsWith(prefix)).array;
  }

  StorageObject[] findByPrefix(TenantId tenantId, BucketId bucketId, string prefix) {
    return filterByPrefix(findByBucket(tenantId, bucketId), prefix);
  }

  void removeByPrefix(TenantId tenantId, BucketId bucketId, string prefix) {
    findByPrefix(tenantId, bucketId, prefix).each!(e => remove(e));
  }

}
