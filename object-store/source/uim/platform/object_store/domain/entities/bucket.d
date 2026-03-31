module uim.platform.object_store.domain.entities.bucket;

import uim.platform.object_store.domain.types;

class Bucket
{
  BucketId id;
  TenantId tenantId;
  string name;
  string region;
  StorageClass storageClass = StorageClass.standard;
  bool versioningEnabled = false;
  EncryptionType encryptionType = EncryptionType.none;
  string encryptionKeyId;
  BucketStatus status = BucketStatus.active;
  long quotaBytes = 0; // 0 = unlimited
  long usedBytes = 0;
  long objectCount = 0;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
