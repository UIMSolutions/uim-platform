/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.storage_object;

import uim.platform.object_store.domain.types;

class StorageObject {
  ObjectId id;
  TenantId tenantId;
  BucketId bucketId;
  string key; // object path, e.g. "images/photo.jpg"
  string contentType;
  long size;
  string etag;
  string metadata; // JSON key-value pairs
  StorageClass storageClass = StorageClass.standard;
  ObjectStatus status = ObjectStatus.active;
  string currentVersionId;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
