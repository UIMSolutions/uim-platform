/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.buckets;
// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.bucket;
// import uim.platform.object_store.domain.ports.repositories.bucket;
// import uim.platform.object_store.domain.services.encryption_policy;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
/// Application service for bucket CRUD operations.
class ManageBucketsUseCase { // TODO: UIMUseCase {
  private BucketRepository repo;

  this(BucketRepository repo) {
    this.repo = repo;
  }

  CommandResult createBucket(CreateBucketRequest req) {
    if (req.name.isEmpty)
      return CommandResult(false, "", "Bucket name is required");
      
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Bucket with name '" ~ req.name ~ "' already exists");

    auto bucket = Bucket(req.tenantId); //, UserId("test-user"));
    bucket.name = req.name;
    bucket.region = req.region;
    bucket.storageClass = req.storageClass.to!StorageClass;
    bucket.versioningEnabled = req.versioningEnabled;
    bucket.encryptionType = req.encryptionType.to!EncryptionType;
    bucket.encryptionKeyId = req.encryptionKeyId;
    bucket.quotaBytes = req.quotaBytes;

    auto encResult = EncryptionPolicy.validate(bucket);
    if (!encResult.valid)
      return CommandResult(false, "", encResult.error);

    repo.save(bucket);
    return CommandResult(true, bucket.id.value, "");
  }

  CommandResult updateBucket(UpdateBucketRequest req) {
    auto bucket = repo.findById(req.tenantId, req.bucketId);
    if (bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    if (req.storageClass.length > 0)
      bucket.storageClass = req.storageClass.to!StorageClass;
    bucket.versioningEnabled = req.versioningEnabled;
    if (req.encryptionType.length > 0)
      bucket.encryptionType = req.encryptionType.to!EncryptionType;
    if (req.encryptionKeyId.length > 0)
      bucket.encryptionKeyId = req.encryptionKeyId;
    if (req.quotaBytes > 0)
      bucket.quotaBytes = req.quotaBytes;
    bucket.updatedAt = currentTimestamp();

    auto encResult = EncryptionPolicy.validate(bucket);
    if (!encResult.valid)
      return CommandResult(false, "", encResult.error);

    repo.update(bucket);
    return CommandResult(true, bucket.id.value, "");
  }

  Bucket getBucket(TenantId tenantId, BucketId id) {
    return repo.findById(tenantId, id);
  }

  Bucket[] listBuckets(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteBucket(TenantId tenantId, BucketId bucketId) {
    auto bucket = repo.findById(tenantId, bucketId);
    if (bucket.isNull)
      return CommandResult(false, "", "Bucket not found");

    if (bucket.objectCount > 0)
      return CommandResult(false, "", "Bucket is not empty");

    repo.remove(bucket);
    return CommandResult(true, bucket.id.value, "");
  }
}

