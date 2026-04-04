/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.buckets;

import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.bucket;
import uim.platform.object_store.domain.ports.repositories.bucket;
import uim.platform.object_store.domain.services.encryption_policy;
import uim.platform.object_store.domain.types;

// import std.conv : to;

/// Application service for bucket CRUD operations.
class ManageBucketsUseCase
{
  private BucketRepository repo;

  this(BucketRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createBucket(CreateBucketRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Bucket name is required");
    if (req.region.length == 0)
      return CommandResult(false, "", "Region is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null && existing.id.length > 0)
      return CommandResult(false, "", "Bucket with name '" ~ req.name ~ "' already exists");

    // import std.uuid : randomUUID;

    auto id = randomUUID().toString();

    auto bucket = new Bucket();
    bucket.id = id;
    bucket.tenantId = req.tenantId;
    bucket.name = req.name;
    bucket.region = req.region;
    bucket.storageClass = parseStorageClass(req.storageClass);
    bucket.versioningEnabled = req.versioningEnabled;
    bucket.encryptionType = parseEncryptionType(req.encryptionType);
    bucket.encryptionKeyId = req.encryptionKeyId;
    bucket.quotaBytes = req.quotaBytes;
    bucket.createdBy = req.createdBy;
    bucket.createdAt = currentTimestamp();
    bucket.updatedAt = bucket.createdAt;

    auto encResult = EncryptionPolicy.validate(bucket);
    if (!encResult.valid)
      return CommandResult(false, "", encResult.error);

    repo.save(bucket);
    return CommandResult(true, id, "");
  }

  CommandResult updateBucket(BucketId id, UpdateBucketRequest req)
  {
    auto bucket = repo.findById(id);
    if (bucket is null || bucket.id.length == 0)
      return CommandResult(false, "", "Bucket not found");

    if (req.storageClass.length > 0)
      bucket.storageClass = parseStorageClass(req.storageClass);
    bucket.versioningEnabled = req.versioningEnabled;
    if (req.encryptionType.length > 0)
      bucket.encryptionType = parseEncryptionType(req.encryptionType);
    if (req.encryptionKeyId.length > 0)
      bucket.encryptionKeyId = req.encryptionKeyId;
    if (req.quotaBytes > 0)
      bucket.quotaBytes = req.quotaBytes;
    bucket.updatedAt = currentTimestamp();

    auto encResult = EncryptionPolicy.validate(bucket);
    if (!encResult.valid)
      return CommandResult(false, "", encResult.error);

    repo.update(bucket);
    return CommandResult(true, id, "");
  }

  Bucket getBucket(BucketId id)
  {
    return repo.findById(id);
  }

  Bucket[] listBuckets(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteBucket(BucketId id)
  {
    auto bucket = repo.findById(id);
    if (bucket is null || bucket.id.length == 0)
      return CommandResult(false, "", "Bucket not found");

    if (bucket.objectCount > 0)
      return CommandResult(false, "", "Bucket is not empty");

    repo.remove(id);
    return CommandResult(true, id, "");
  }
}

private StorageClass parseStorageClass(string s)
{
  switch (s)
  {
  case "nearline":
    return StorageClass.nearline;
  case "coldline":
    return StorageClass.coldline;
  case "archive":
    return StorageClass.archive;
  default:
    return StorageClass.standard;
  }
}

private EncryptionType parseEncryptionType(string s)
{
  switch (s)
  {
  case "sse_s3":
    return EncryptionType.sse_s3;
  case "sse_kms":
    return EncryptionType.sse_kms;
  case "sse_c":
    return EncryptionType.sse_c;
  default:
    return EncryptionType.none;
  }
}

private long currentTimestamp()
{
  import core.time : Duration;

  // import std.datetime.systime : Clock;

  return Clock.currStdTime();
}
