module uim.platform.object_store.application.usecases.manage_objects;

import uim.platform.object_store.application.dto;
import uim.platform.object_store.domain.entities.bucket;
import uim.platform.object_store.domain.entities.storage_object;
import uim.platform.object_store.domain.entities.object_version;
import uim.platform.object_store.domain.ports.repositories.bucket;
import uim.platform.object_store.domain.ports.repositories.storage_object;
import uim.platform.object_store.domain.ports.repositories.object_version;
import uim.platform.object_store.domain.services.quota_validator;
import uim.platform.object_store.domain.types;

// import std.conv : to;

/// Application service for storage object CRUD operations.
class ManageObjectsUseCase
{
    private StorageObjectRepository objectRepo;
    private BucketRepository bucketRepo;
    private ObjectVersionRepository versionRepo;

    this(StorageObjectRepository objectRepo, BucketRepository bucketRepo, ObjectVersionRepository versionRepo)
    {
        this.objectRepo = objectRepo;
        this.bucketRepo = bucketRepo;
        this.versionRepo = versionRepo;
    }

    CommandResult createObject(CreateObjectRequest req)
    {
        if (req.bucketId.length == 0)
            return CommandResult(false, "", "Bucket ID is required");
        if (req.key.length == 0)
            return CommandResult(false, "", "Object key is required");

        auto bucket = bucketRepo.findById(req.bucketId);
        if (bucket is null || bucket.id.length == 0)
            return CommandResult(false, "", "Bucket not found");
        if (bucket.status != BucketStatus.active)
            return CommandResult(false, "", "Bucket is not active");

        // Quota check
        auto quotaResult = QuotaValidator.validate(bucket, req.size);
        if (!quotaResult.valid)
            return CommandResult(false, "", quotaResult.error);

        // import std.uuid : randomUUID;
        auto id = randomUUID().toString();
        auto ts = currentTimestamp();

        auto obj = new StorageObject();
        obj.id = id;
        obj.tenantId = req.tenantId;
        obj.bucketId = req.bucketId;
        obj.key = req.key;
        obj.contentType = req.contentType.length > 0 ? req.contentType : "application/octet-stream";
        obj.size = req.size;
        obj.etag = generateEtag(id);
        obj.metadata = req.metadata;
        obj.storageClass = parseStorageClass(req.storageClass);
        obj.createdBy = req.createdBy;
        obj.createdAt = ts;
        obj.updatedAt = ts;

        // Create initial version if versioning is enabled
        if (bucket.versioningEnabled)
        {
            auto versionId = randomUUID().toString();
            auto ver = new ObjectVersion();
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
            ver.createdAt = ts;
            obj.currentVersionId = versionId;
            versionRepo.save(ver);
        }

        objectRepo.save(obj);

        // Update bucket counters
        bucket.objectCount = bucket.objectCount + 1;
        bucket.usedBytes = bucket.usedBytes + req.size;
        bucket.updatedAt = ts;
        bucketRepo.update(bucket);

        return CommandResult(true, id, "");
    }

    CommandResult updateObjectMetadata(ObjectId id, UpdateObjectMetadataRequest req)
    {
        auto obj = objectRepo.findById(id);
        if (obj is null || obj.id.length == 0)
            return CommandResult(false, "", "Object not found");

        if (req.contentType.length > 0) obj.contentType = req.contentType;
        if (req.metadata.length > 0) obj.metadata = req.metadata;
        if (req.storageClass.length > 0) obj.storageClass = parseStorageClass(req.storageClass);
        obj.updatedAt = currentTimestamp();

        objectRepo.update(obj);
        return CommandResult(true, id, "");
    }

    StorageObject getObject(ObjectId id)
    {
        return objectRepo.findById(id);
    }

    StorageObject getObjectByKey(BucketId bucketId, string key)
    {
        return objectRepo.findByKey(bucketId, key);
    }

    StorageObject[] listObjects(BucketId bucketId)
    {
        return objectRepo.findByBucket(bucketId);
    }

    StorageObject[] listObjectsByPrefix(BucketId bucketId, string prefix)
    {
        return objectRepo.findByPrefix(bucketId, prefix);
    }

    ObjectVersion[] listVersions(ObjectId objectId)
    {
        return versionRepo.findByObject(objectId);
    }

    CommandResult deleteObject(ObjectId id)
    {
        auto obj = objectRepo.findById(id);
        if (obj is null || obj.id.length == 0)
            return CommandResult(false, "", "Object not found");

        auto bucket = bucketRepo.findById(obj.bucketId);

        // If versioning enabled, add a delete marker instead of removing
        if (bucket !is null && bucket.versioningEnabled)
        {
            // import std.uuid : randomUUID;
            auto versionId = randomUUID().toString();
            auto ts = currentTimestamp();

            // Mark current latest as not latest
            auto currentLatest = versionRepo.findLatest(id);
            if (currentLatest !is null && currentLatest.id.length > 0)
            {
                currentLatest.isLatest = false;
                versionRepo.save(currentLatest);
            }

            auto marker = new ObjectVersion();
            marker.id = versionId;
            marker.tenantId = obj.tenantId;
            marker.objectId = id;
            marker.versionTag = "delete-marker";
            marker.isLatest = true;
            marker.isDeleteMarker = true;
            marker.createdBy = "";
            marker.createdAt = ts;
            versionRepo.save(marker);

            obj.status = ObjectStatus.deleted;
            obj.updatedAt = ts;
            objectRepo.update(obj);
        }
        else
        {
            // Hard delete
            versionRepo.removeByObject(id);
            objectRepo.remove(id);
        }

        // Update bucket counters
        if (bucket !is null)
        {
            bucket.objectCount = bucket.objectCount > 0 ? bucket.objectCount - 1 : 0;
            bucket.usedBytes = bucket.usedBytes > obj.size ? bucket.usedBytes - obj.size : 0;
            bucket.updatedAt = currentTimestamp();
            bucketRepo.update(bucket);
        }

        return CommandResult(true, id, "");
    }

    CommandResult copyObject(CopyObjectRequest req)
    {
        auto sourceObj = objectRepo.findByKey(req.sourceBucketId, req.sourceKey);
        if (sourceObj is null || sourceObj.id.length == 0)
            return CommandResult(false, "", "Source object not found");

        auto destBucket = bucketRepo.findById(req.destBucketId);
        if (destBucket is null || destBucket.id.length == 0)
            return CommandResult(false, "", "Destination bucket not found");

        auto quotaResult = QuotaValidator.validate(destBucket, sourceObj.size);
        if (!quotaResult.valid)
            return CommandResult(false, "", quotaResult.error);

        // import std.uuid : randomUUID;
        auto id = randomUUID().toString();
        auto ts = currentTimestamp();

        auto copy = new StorageObject();
        copy.id = id;
        copy.tenantId = req.tenantId;
        copy.bucketId = req.destBucketId;
        copy.key = req.destKey;
        copy.contentType = sourceObj.contentType;
        copy.size = sourceObj.size;
        copy.etag = generateEtag(id);
        copy.metadata = sourceObj.metadata;
        copy.storageClass = sourceObj.storageClass;
        copy.createdBy = req.createdBy;
        copy.createdAt = ts;
        copy.updatedAt = ts;

        objectRepo.save(copy);

        destBucket.objectCount = destBucket.objectCount + 1;
        destBucket.usedBytes = destBucket.usedBytes + sourceObj.size;
        destBucket.updatedAt = ts;
        bucketRepo.update(destBucket);

        return CommandResult(true, id, "");
    }
}

private StorageClass parseStorageClass(string s)
{
    switch (s)
    {
    case "nearline": return StorageClass.nearline;
    case "coldline": return StorageClass.coldline;
    case "archive": return StorageClass.archive;
    default: return StorageClass.standard;
    }
}

private string generateEtag(string id)
{
    // import std.digest.md : md5Of, toHexString;
    // import std.string : representation;
    auto hash = md5Of(id.representation);
    return toHexString(hash).idup;
}

private long currentTimestamp()
{
    // import std.datetime.systime : Clock;
    return Clock.currStdTime();
}
