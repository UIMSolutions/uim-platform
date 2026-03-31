module uim.platform.object_store.domain.entities.storage_object;

import uim.platform.object_store.domain.types;

class StorageObject
{
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
