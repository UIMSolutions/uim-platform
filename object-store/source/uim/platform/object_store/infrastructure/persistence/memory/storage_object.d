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
// import std.array : array;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryStorageObjectRepository : StorageObjectRepository {
  private StorageObject[ObjectId] store;

  bool existsById(ObjectId id) {
    return (id in store) ? true : false;
  }

  StorageObject findById(ObjectId id) {
    return existsById(id) ? store[id] : StorageObject.init;
  }

  bool existsByKey(BucketId bucketId, string key) {
    return findAll().filter!(e => e.bucketId == bucketId && e.key == key && e.status == ObjectStatus.active).length > 0;
  }

  StorageObject findByKey(BucketId bucketId, string key) {
    foreach (e; findAll())
      if (e.bucketId == bucketId && e.key == key && e.status == ObjectStatus.active)
        return e;
    return StorageObject.init;
  }

  StorageObject[] findByBucket(BucketId bucketId) {
    return findAll().filter!(e => e.bucketId == bucketId
        && e.status == ObjectStatus.active).array;
  }

  StorageObject[] findByPrefix(BucketId bucketId, string prefix) {
    return findAll().filter!(e => e.bucketId == bucketId
        && e.status == ObjectStatus.active && e.key.startsWith(prefix)).array;
  }

  void save(StorageObject entity) {
    store[entity.id] = entity;
  }

  void update(StorageObject entity) {
    store[entity.id] = entity;
  }

  void remove(ObjectId id) {
    removeById(id);
  }
}
