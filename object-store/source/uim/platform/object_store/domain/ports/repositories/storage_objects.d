/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.storage_object;

// import uim.platform.object_store.domain.entities.storage_object;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Port: outgoing - storage object persistence.
interface StorageObjectRepository {
  bool existsById(ObjectId id);
  StorageObject findById(ObjectId id);
  
  bool existsByKey(BucketId bucketId, string key);
  StorageObject findByKey(BucketId bucketId, string key);
  
  StorageObject[] findByBucket(BucketId bucketId);
  StorageObject[] findByPrefix(BucketId bucketId, string prefix);

  void save(StorageObject obj);
  void update(StorageObject obj);
  void remove(ObjectId id);
}
