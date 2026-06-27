/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.ports.repositories.object_versions;

// import uim.platform.object_store.domain.entities.object_version;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Port: outgoing - object version persistence.
interface ObjectVersionRepository : ITentRepository!(ObjectVersion, ObjectVersionId) {

  bool existsLatest(TenantId tenantId, StorageObjectId objectId);
  ObjectVersion findLatest(TenantId tenantId, StorageObjectId objectId);

  size_t countByObject(TenantId tenantId, StorageObjectId objectId);
  ObjectVersion[] findByObject(TenantId tenantId, StorageObjectId objectId);
  void removeByObject(TenantId tenantId, StorageObjectId objectId);
    
}
