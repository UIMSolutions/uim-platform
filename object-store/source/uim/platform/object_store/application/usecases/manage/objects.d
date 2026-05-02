/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.objects;

// import uim.platform.object_store.application.dto;
// import uim.platform.object_store.domain.entities.bucket;
// import uim.platform.object_store.domain.entities.storage_object;
// import uim.platform.object_store.domain.entities.object_version;
// import uim.platform.object_store.domain.ports.repositories.bucket;
// import uim.platform.object_store.domain.ports.repositories.storage_object;
// import uim.platform.object_store.domain.ports.repositories.object_version;
// import uim.platform.object_store.domain.services.quota_validator;
// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
// import std.conv : to;

/// Application service for storage object CRUD operations.
class ManageObjectsUseCase { // TODO: UIMUseCase {
  private StorageObjectRepository objectRepo;
  private BucketRepository bucketRepo;
  private ObjectVersionRepository versionRepo;

  this(StorageObjectRepository objectRepo, BucketRepository bucketRepo,
    ObjectVersionRepository versionRepo) {
    this.objectRepo = objectRepo;
    this.bucketRepo = bucketRepo;
    this.versionRepo = versionRepo;
  }

  CommandResult createObject(CreateObjectRequest req) {
    if (req.bucketId.isEmpty)
      return CommandResult(false, "", "Bucket ID is required");
    if (req.key.length == 0)
      return CommandResult(false, "", "Object key is required");

    auto bucket = bucketRepo.findById(req.bucketId);
    if (bucket.isNull || bucket.isNull)
      return CommandResult(false, "", "Bucket not found");
    if (bucket.status != BucketStatus.active)
      return CommandResult(false, "", "Bucket is not active");

    // Quota check
    auto quotaResult = QuotaValidator.validate(bucket, req.size);
    if (!quotaResult.valid)
      return CommandResult(false, "", quotaResult.error);

    StorageObject obj;
    obj.id = randomUUID();
    obj.tenantId = req.tenantId;
    obj.bucketId = req.bucketId;
    obj.key = req.key;
    obj.contentType = req.contentType.length > 0 ? req.contentType : "application/octet-stream";
    obj.size = req.size;
    obj.etag = generateEtag(id);
    obj.metadata = req.metadata;
    obj.storageClass = parseStorageClass(req.storageClass);
    obj.createdBy = req.createdBy;
    obj.createdAt = currentTimestamp();
    ;
    obj.updatedAt = obj.createdAt;

    // Create initial version if versioning is enabled
    if (bucket.versioningEnabled) {
      auto versionId = randomUUID();
      ObjectVersion ver;
      ver.id = versionId;
      ver.tenantId = req.tenantId;
      ver.objectId = id;
      ver.versionTag = "v1";
      ver.size = req.size;
      ver.etag = obj.etag;
      ver.contentType = obj.contentType;
      ver.isLatest = true;
      ver.isDeleteMarker = false;
      ver.createdBy = req.createdBy;
      ver.createdAt = obj.createdAt;
      obj.currentVersionId = versionId;
      versionRepo.save(ver);
    }

    objectRepo.save(obj);

    // Update bucket counters
    bucket.objectCount = bucket.objectCount + 1;
    bucket.usedBytes = bucket.usedBytes + req.size;
    bucket.updatedAt = obj.createdAt;
    bucketRepo.update(bucket);

    return CommandResult(true, obj.id.value, "");
  }

  CommandResult updateObjectMetadata(ObjectId id, UpdateObjectMetadataRequest req) {
    auto obj = objectRepo.findById(id);
    if (obj.isNull || obj.isNull)
      return CommandResult(false, "", "Object not found");

    if (req.contentType.length > 0)
      obj.contentType = req.contentType;
    if (req.metadata.length > 0)
      obj.metadata = req.metadata;
    if (req.storageClass.length > 0)
      obj.storageClass = parseStorageClass(req.storageClass);
    obj.updatedAt = currentTimestamp();

    objectRepo.update(obj);
    return CommandResult(true, id.value, "");
  }

  StorageObject getObject(ObjectId id) {
    return objectRepo.findById(id);
  }

  StorageObject getObjectByKey(BucketId bucketId, string key) {
    return objectRepo.findByKey(bucketId, key);
  }

  StorageObject[] listObjects(BucketId bucketId) {
    return objectRepo.findByBucket(bucketId);
  }

  StorageObject[] listObjectsByPrefix(BucketId bucketId, string prefix) {
    return objectRepo.findByPrefix(bucketId, prefix);
  }

  ObjectVersion[] listVersions(ObjectId objectId) {
    return versionRepo.findByObject(objectId);
  }

  CommandResult deleteObject(ObjectId id) {
    auto obj = objectRepo.findById(id);
    if (obj.isNull)
      return CommandResult(false, "", "Object not found");

    auto bucket = bucketRepo.findById(obj.bucketId);

    // If versioning enabled, add a delete marker instead of removing
    if (bucket !is null && bucket.versioningEnabled) {
      // import std.uuid : randomUUID;
      auto versionId = randomUUID();
      auto ts = currentTimestamp();

      // Mark current latest as not latest
      auto currentLatest = versionRepo.findLatest(id);
      if (currentLatest !is null && currentLatest.id.length > 0) {
        currentLatest.isLatest = false;
        versionRepo.save(currentLatest);
      }

      ObjectVersion marker;
      marker.id = versionId;
      marker.tenantId = obj.tenantId;
      marker.objectId = id;
      marker.versionTag = "delete-marker";
      marker.isLatest = true;
      marker.isDeleteMarker = true;
      marker.createdBy = "";
      marker.createdAt = obj.createdAt;
      versionRepo.save(marker);

      obj.status = ObjectStatus.deleted;
      obj.updatedAt = obj.createdAt;
      objectRepo.update(obj);
    } else {
      // Hard delete
      versionRepo.removeByObject(id);
      objectRepo.removeById(id);
    }

    // Update bucket counters
    if (bucket !is null) {
      bucket.objectCount = bucket.objectCount > 0 ? bucket.objectCount - 1 : 0;
      bucket.usedBytes = bucket.usedBytes > obj.size ? bucket.usedBytes - obj.size : 0;
      bucket.updatedAt = currentTimestamp();
      bucketRepo.update(bucket);
    }

    return CommandResult(true, id.value, "");
  }

  CommandResult copyObject(CopyObjectRequest req) {
    auto sourceObj = objectRepo.findByKey(req.sourceBucketId, req.sourceKey);
    if (sourceObj.isNull || sourceObj.isNull)
      return CommandResult(false, "", "Source object not found");

    auto destBucket = bucketRepo.findById(req.destBucketId);
    if (destBucket.isNull || destBucket.isNull)
      return CommandResult(false, "", "Destination bucket not found");

    auto quotaResult = QuotaValidator.validate(destBucket, sourceObj.size);
    if (!quotaResult.valid)
      return CommandResult(false, "", quotaResult.error);

    auto copy = new StorageObject();
    copy.id = randomUUID();
    copy.tenantId = req.tenantId;
    copy.bucketId = req.destBucketId;
    copy.key = req.destKey;
    copy.contentType = sourceObj.contentType;
    copy.size = sourceObj.size;
    copy.etag = generateEtag(id);
    copy.metadata = sourceObj.metadata;
    copy.storageClass = sourceObj.storageClass;
    copy.createdBy = req.createdBy;
    copy.createdAt = currentTimestamp();
    copy.updatedAt = copy.createdAt;

    objectRepo.save(copy);

    destBucket.objectCount = destBucket.objectCount + 1;
    destBucket.usedBytes = destBucket.usedBytes + sourceObj.size;
    destBucket.updatedAt = copy.createdAt;
    bucketRepo.update(destBucket);

    return CommandResult(true, copy.id.value, "");
  }
}

private StorageClass parseStorageClass(string storage) {
  switch (storage) {
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

private string generateEtag(string id) {
  // import std.digest.md : md5Of, toHexString;
  // import std.string : representation;
  auto hash = md5Of(id.representation);
  return toHexString(hash).idup;
}

private long currentTimestamp() {
  // import std.datetime.systime : Clock;
  return Clock.currStdTime();
}
