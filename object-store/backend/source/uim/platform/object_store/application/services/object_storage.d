/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Application service shared by the object, version, bucket and lifecycle
/// interactors: writes content and versions, deletes with delete markers,
/// collects unreferenced blobs and keeps the bucket usage up to date.
module uim.platform.object_store.application.services.object_storage;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// What to write: content (data) or an already stored blob (copy, promote).
struct ContentSource {
  const(ubyte)[] data;
  string blobId; /// set → reuse this blob (size / etag must be given)
  long size;
  string etag;
}

class ObjectStorageService {
  protected ObjectStoreRepositories repos;
  protected IBlobStorage blobs;
  protected StorageLimits limits;

  this(ObjectStoreRepositories repos, IBlobStorage blobs, StorageLimits limits) {
    this.repos = repos;
    this.blobs = blobs;
    this.limits = limits;
  }

  StorageLimits storageLimits() const {
    return limits;
  }

  // ── lookups ────────────────────────────────────────────────────────────

  Bucket requireBucket(TenantId tenantId, BucketId id) {
    validate(!id.isEmpty, "bucketId is required");
    auto bucket = repos.buckets.findById(tenantId, id);
    if (bucket.isNull)
      throw new ObjectStoreNotFoundException("Bucket '" ~ id.value ~ "' not found");
    return bucket;
  }

  StorageObject requireObject(TenantId tenantId, StorageObjectId id) {
    auto obj = repos.objects.findById(tenantId, id);
    if (obj.isNull)
      throw new ObjectStoreNotFoundException("Object '" ~ id.value ~ "' not found");
    return obj;
  }

  StorageObject requireObjectByKey(TenantId tenantId, BucketId bucketId, string key) {
    auto obj = repos.objects.findByName(tenantId, bucketId, key);
    if (obj.isNull)
      throw new ObjectStoreNotFoundException("Object '" ~ key ~ "' not found");
    return obj;
  }

  /// The latest stored (non delete marker) version of an object.
  ObjectVersion latestContent(TenantId tenantId, StorageObjectId id) {
    foreach (v; repos.versions.findByObject(tenantId, id))
      if (!v.isDeleteMarker)
        return v;
    return ObjectVersion.init;
  }

  // ── writing ────────────────────────────────────────────────────────────

  /// Write a new version of `key`. Creates the object if needed; without
  /// versioning, older versions are purged. Returns the updated object.
  StorageObject write(Bucket bucket, string key, ContentSource content, string contentType,
      MetadataEntry[] metadata, bool replaceMetadata, StorageClass storageClass, bool keepStorageClass,
      UserId actor) {
    ensureWritable(bucket);
    validateObjectKey(key, limits.maxKeyLength);
    auto t = bucket.tenantId;

    auto size = content.blobId.length > 0 ? content.size : cast(long) content.data.length;
    if (size > limits.maxObjectSize)
      throw new ObjectStoreException("Object '%s' is %d bytes; the limit is %d bytes".format(key, size,
          limits.maxObjectSize), 413);

    auto obj = repos.objects.findByName(t, bucket.id, key);
    bool exists = !obj.isNull;
    if (exists) {
      ensureNotOnHold(obj);
      ensureState(obj.status != ObjectStatus.archived, "Object '" ~ key ~ "' is archived — restore it first");
    }

    // Quota: versioned buckets keep the old content, others replace it.
    long released;
    if (exists && !bucket.versioningEnabled)
      foreach (v; repos.versions.findByObject(t, obj.id))
        released += v.size;
    ensureQuota(bucket, size - released);

    string blobId = content.blobId, etag = content.etag;
    if (blobId.length == 0) {
      blobId = blobs.put(t, content.data);
      etag = contentEtag(content.data);
    }

    if (!exists) {
      obj = StorageObject(t);
      obj.bucketId = bucket.id;
      obj.bucketName = bucket.name;
      obj.name = key;
      obj.createdBy = actor;
      obj.storageClass = bucket.storageClass;
    }
    auto previous = repos.versions.findByObject(t, obj.id);
    auto number = previous.length > 0 ? previous[0].versionNumber + 1 : 1;

    auto v = ObjectVersion(t);
    v.objectId = obj.id;
    v.bucketId = bucket.id;
    v.objectKey = key;
    v.versionNumber = number;
    v.name = versionName(number);
    v.size = size;
    v.etag = etag;
    v.contentType = contentType.length > 0 ? contentType : exists ? obj.contentType : "application/octet-stream";
    v.blobId = blobId;
    v.isLatest = true;
    v.createdBy = actor;
    v.updatedBy = actor;
    repos.versions.save(v);

    foreach (old; previous) {
      if (!bucket.versioningEnabled)
        purge(old);
      else if (old.isLatest) {
        old.isLatest = false;
        repos.versions.update(old);
      }
    }

    obj.contentType = v.contentType;
    obj.size = size;
    obj.etag = etag;
    if (replaceMetadata || !exists)
      obj.metadata = metadata;
    if (!keepStorageClass)
      obj.storageClass = storageClass;
    obj.status = ObjectStatus.active;
    obj.currentVersion = number;
    obj.currentVersionId = v.id;
    obj.versionCount = cast(int) repos.versions.findByObject(t, obj.id).length;
    obj.update(actor);
    if (exists)
      repos.objects.update(obj);
    else
      repos.objects.save(obj);
    recount(t, bucket.id);
    return obj;
  }

  /// Delete an object. Versioned buckets get a delete marker (the versions
  /// stay and can be promoted); deleting an object that is already deleted,
  /// or any object of an unversioned bucket, removes it permanently.
  /// Returns true if the object was removed permanently.
  bool deleteObject(StorageObject obj, UserId actor) {
    auto bucket = requireBucket(obj.tenantId, obj.bucketId);
    ensureWritable(bucket);
    ensureNotOnHold(obj);
    auto t = obj.tenantId;

    if (!bucket.versioningEnabled || obj.status == ObjectStatus.deleted) {
      purgeObject(obj);
      recount(t, bucket.id);
      return true;
    }

    auto previous = repos.versions.findByObject(t, obj.id);
    foreach (old; previous)
      if (old.isLatest) {
        old.isLatest = false;
        repos.versions.update(old);
      }
    auto marker = ObjectVersion(t);
    marker.objectId = obj.id;
    marker.bucketId = obj.bucketId;
    marker.objectKey = obj.name;
    marker.versionNumber = previous.length > 0 ? previous[0].versionNumber + 1 : 1;
    marker.name = versionName(marker.versionNumber) ~ " (delete marker)";
    marker.isLatest = true;
    marker.isDeleteMarker = true;
    marker.createdBy = actor;
    repos.versions.save(marker);

    obj.status = ObjectStatus.deleted;
    obj.currentVersion = marker.versionNumber;
    obj.currentVersionId = marker.id;
    obj.versionCount = cast(int) previous.length + 1;
    obj.update(actor);
    repos.objects.update(obj);
    recount(t, bucket.id);
    return false;
  }

  /// Remove an object with all versions and unreferenced blobs.
  void purgeObject(StorageObject obj) {
    foreach (v; repos.versions.findByObject(obj.tenantId, obj.id))
      purge(v);
    repos.objects.remove(obj);
  }

  /// Permanently delete one version. If it was the latest, the next older
  /// version becomes the latest; an object without versions is removed.
  void purgeVersion(ObjectVersion version_, UserId actor) {
    auto t = version_.tenantId;
    auto obj = repos.objects.findById(t, version_.objectId);
    if (!obj.isNull) {
      ensureNotOnHold(obj);
      ensureWritable(requireBucket(t, obj.bucketId));
    }
    purge(version_);
    if (obj.isNull)
      return;

    auto rest = repos.versions.findByObject(t, obj.id);
    if (rest.length == 0) {
      repos.objects.remove(obj);
    } else {
      auto top = rest[0];
      if (!top.isLatest) {
        top.isLatest = true;
        repos.versions.update(top);
      }
      obj.currentVersion = top.versionNumber;
      obj.currentVersionId = top.id;
      obj.versionCount = cast(int) rest.length;
      if (top.isDeleteMarker) {
        obj.status = ObjectStatus.deleted;
      } else {
        if (obj.status == ObjectStatus.deleted)
          obj.status = ObjectStatus.active;
        obj.size = top.size;
        obj.etag = top.etag;
        obj.contentType = top.contentType;
      }
      obj.update(actor);
      repos.objects.update(obj);
    }
    recount(t, obj.bucketId);
  }

  /// Remove a version record and its blob if nothing else references it.
  protected void purge(ObjectVersion v) {
    repos.versions.remove(v);
    if (v.blobId.length > 0 && repos.versions.countByBlob(v.tenantId, v.blobId) == 0)
      blobs.remove(v.tenantId, v.blobId);
  }

  // ── reading ────────────────────────────────────────────────────────────

  ObjectContent read(TenantId tenantId, BucketId bucketId, string key, int versionNumber) {
    auto obj = requireObjectByKey(tenantId, bucketId, key);
    ObjectContent c;
    c.object = obj;
    if (versionNumber > 0) {
      foreach (v; repos.versions.findByObject(tenantId, obj.id))
        if (v.versionNumber == versionNumber)
          c.version_ = v;
      if (c.version_.isNull)
        throw new ObjectStoreNotFoundException("Object '%s' has no version %d".format(key, versionNumber));
      if (c.version_.isDeleteMarker)
        throw new ObjectStoreNotFoundException("Version %d of '%s' is a delete marker".format(versionNumber, key));
      ensureState(obj.status != ObjectStatus.archived, "Object '" ~ key ~ "' is archived — restore it first");
    } else {
      ensureReadable(obj);
      c.version_ = latestContent(tenantId, obj.id);
      if (c.version_.isNull)
        throw new ObjectStoreNotFoundException("Object '" ~ key ~ "' has no content");
    }
    c.data = blobs.get(tenantId, c.version_.blobId);
    return c;
  }

  // ── usage ──────────────────────────────────────────────────────────────

  /// Recompute usedBytes, objectCount and versionCount of a bucket.
  void recount(TenantId tenantId, BucketId bucketId) {
    auto bucket = repos.buckets.findById(tenantId, bucketId);
    if (bucket.isNull)
      return;
    long bytes;
    int versions, objects;
    foreach (v; repos.versions.findByBucket(tenantId, bucketId))
      if (!v.isDeleteMarker) {
        bytes += v.size;
        versions++;
      }
    foreach (o; repos.objects.findByBucket(tenantId, bucketId))
      if (o.status != ObjectStatus.deleted)
        objects++;
    if (bucket.usedBytes == bytes && bucket.objectCount == objects && bucket.versionCount == versions)
      return;
    bucket.usedBytes = bytes;
    bucket.objectCount = objects;
    bucket.versionCount = versions;
    repos.buckets.update(bucket);
  }
}
