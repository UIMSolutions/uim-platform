/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.persistence.memory.object_version;

// import uim.platform.object_store.domain.types;
// import uim.platform.object_store.domain.entities.object_version;
// import uim.platform.object_store.domain.ports.repositories.object_version;
// 

 
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
class MemoryObjectVersionRepository : TentRepository!(ObjectVersion, ObjectVersionId),  ObjectVersionRepository {

  bool existsLatest(TenantId tenantId, StorageObjectId objectId) {
    return findByTenant(tenantId).any!(e => e.objectId == objectId && e.isLatest);
  }

  ObjectVersion findLatest(TenantId tenantId, StorageObjectId objectId) {
    foreach (e; findByTenant(tenantId))
      if (e.objectId == objectId && e.isLatest)
        return e;
    return ObjectVersion.init;
  }

  void removeLatest(TenantId tenantId, StorageObjectId objectId) {
    remove(findLatest(tenantId, objectId));
  }

  size_t countByObject(TenantId tenantId, StorageObjectId objectId) {
    return findByObject(tenantId, objectId).length;
  }

  ObjectVersion[] filterByObject(ObjectVersion[] versions, StorageObjectId objectId) {
    return versions.filter!(e => e.objectId == objectId).array;
  }

  ObjectVersion[] findByObject(TenantId tenantId, StorageObjectId objectId) {
    return findByTenant(tenantId).filter!(e => e.objectId == objectId).array;
  }

  void removeByObject(TenantId tenantId, StorageObjectId objectId) {
    findByObject(tenantId, objectId).each!(v => remove(v));
  }

}
