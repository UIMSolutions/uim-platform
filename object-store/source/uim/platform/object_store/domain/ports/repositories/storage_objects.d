/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.storage_objects;

// import uim.platform.object_store.domain.entities.storage_object;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

// mixin(ShowModule!());

@safe:
/// Port: outgoing - storage object persistence.
interface StorageObjectRepository : ITenantRepository!(StorageObject, StorageObjectId) {

  bool existsByKey(TenantId tenantId, BucketId bucketId, string key);
  StorageObject findByKey(TenantId tenantId, BucketId bucketId, string key);
  
  size_t countByBucket(TenantId tenantId, BucketId bucketId);
  StorageObject[] findByBucket(TenantId tenantId, BucketId bucketId);
  void removeByBucket(TenantId tenantId, BucketId bucketId);

  size_t countByPrefix(TenantId tenantId, BucketId bucketId, string prefix);
  StorageObject[] findByPrefix(TenantId tenantId, BucketId bucketId, string prefix);
  void removeByPrefix(TenantId tenantId, BucketId bucketId, string prefix);

} 
