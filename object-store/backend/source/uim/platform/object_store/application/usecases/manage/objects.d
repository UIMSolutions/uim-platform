/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.objects;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Interactor: objects. Keys are unique per bucket and fixed; every content
/// write creates a version (see ObjectStorageService for the rules).
class ManageObjectsUseCase
  : ResourceUseCase!(StorageObject, StorageObjectId, CreateObjectRequest, UpdateObjectRequest),
  IManageObjectsUseCase {

  protected ObjectStorageService storage;

  this(ObjectStoreRepositories repos, EventRecorder events, ObjectStorageService storage) {
    super(repos, repos.objects, events, "Object", "objectstore.object");
    this.storage = storage;
  }

  // create / update / remove are overridden: they work on content and versions
  override protected StorageObject build(CreateObjectRequest r) {
    assert(0, "ManageObjectsUseCase.create is overridden");
  }

  override protected void apply(ref StorageObject o, ObjectSpec spec) {
    assert(0, "ManageObjectsUseCase.update is overridden");
  }

  override UsecaseResult create(CreateObjectRequest r) {
    return guarded(() {
      validate(!r.tenantId.isEmpty, "Tenant ID is required");
      auto bucket = storage.requireBucket(r.tenantId, r.parentId);
      auto key = r.spec.name;
      ensureState(repos.objects.findByName(r.tenantId, bucket.id, key).isNull,
        "Object '" ~ key ~ "' already exists in bucket '" ~ bucket.name ~ "' — update it to write a new version");
      auto data = decodeContent(r.spec.content, r.spec.contentEncoding);
      auto storageClass = r.spec.storageClass == StorageClass.standard ? bucket.storageClass : r.spec.storageClass;
      ensureState(storageClass != StorageClass.archive, "Objects cannot be created in the archive storage class");
      auto obj = storage.write(bucket, key, ContentSource(data), r.spec.contentType, r.spec.metadata, true,
        storageClass, false, r.actor);
      publish(obj, "created");
      return succeeded(obj.id.value, "Object '%s' created in '%s' (%d bytes)".format(key, bucket.name, obj.size));
    });
  }

  override UsecaseResult update(UpdateObjectRequest r) {
    return guarded(() {
      auto obj = require(r.tenantId, r.id);
      auto bucket = storage.requireBucket(r.tenantId, obj.bucketId);
      if (r.spec.content.length > 0) {
        ensureState(r.spec.storageClass != StorageClass.archive, "Archive the object after writing its content");
        obj = storage.write(bucket, obj.name, ContentSource(decodeContent(r.spec.content, r.spec.contentEncoding)),
          r.spec.contentType, r.spec.metadata, true, r.spec.storageClass, false, r.actor);
        publish(obj, "written");
        return succeeded(obj.id.value, "Object '%s' written (version %d, %d bytes)".format(obj.name,
          obj.currentVersion, obj.size));
      }
      ensureWritable(bucket);
      ensureState(obj.status != ObjectStatus.deleted, "Object '" ~ obj.name ~ "' is deleted");
      if (r.spec.contentType.strip.length > 0)
        obj.contentType = r.spec.contentType.strip;
      obj.metadata = r.spec.metadata;
      if (r.spec.storageClass != obj.storageClass) {
        if (r.spec.storageClass == StorageClass.archive)
          obj.status = ObjectStatus.archived;
        else if (obj.status == ObjectStatus.archived)
          obj.status = ObjectStatus.active;
        obj.storageClass = r.spec.storageClass;
      }
      obj.update(r.actor);
      repos.objects.update(obj);
      publish(obj, "updated");
      return succeeded(obj.id.value, "Object '" ~ obj.name ~ "' updated");
    });
  }

  override UsecaseResult remove(TenantId tenantId, StorageObjectId id, UserId actor) {
    return guarded(() {
      auto obj = require(tenantId, id);
      auto permanent = storage.deleteObject(obj, actor);
      publish(obj, permanent ? "deleted" : "deleteMarked");
      return succeeded(obj.id.value, permanent ? "Object '" ~ obj.name ~ "' deleted permanently"
        : "Object '" ~ obj.name ~ "' deleted (delete marker; versions are kept)");
    });
  }

  // ── data plane ─────────────────────────────────────────────────────────

  UsecaseResult put(PutObjectRequest r) {
    return guarded(() {
      auto bucket = storage.requireBucket(r.tenantId, r.bucketId);
      auto existing = repos.objects.findByName(r.tenantId, bucket.id, r.key);
      auto obj = storage.write(bucket, r.key, ContentSource(r.data), r.contentType, r.metadata,
        r.replaceMetadata || existing.isNull, bucket.storageClass, !existing.isNull, r.actor);
      publish(obj, "written");
      return succeeded(obj.id.value, "Object '%s' written (version %d, %d bytes)".format(obj.name,
        obj.currentVersion, obj.size));
    });
  }

  ObjectContent read(TenantId tenantId, BucketId bucketId, string key, int versionNumber = 0) {
    storage.requireBucket(tenantId, bucketId);
    return storage.read(tenantId, bucketId, key, versionNumber);
  }

  ObjectListing listing(TenantId tenantId, BucketId bucketId, string prefix, string delimiter) {
    auto bucket = storage.requireBucket(tenantId, bucketId);
    ObjectListing l;
    l.bucketName = bucket.name;
    l.prefix = prefix;
    l.delimiter = delimiter;
    bool[string] seen;
    foreach (o; repos.objects.findByPrefix(tenantId, bucketId, prefix)) {
      if (o.status == ObjectStatus.deleted)
        continue;
      if (delimiter.length > 0) {
        auto rest = o.name[prefix.length .. $];
        auto at = rest.indexOf(delimiter);
        if (at >= 0) {
          auto folder = prefix ~ rest[0 .. at + delimiter.length];
          if (folder !in seen) {
            seen[folder] = true;
            l.commonPrefixes ~= folder;
          }
          continue;
        }
      }
      l.objects ~= o;
    }
    return l;
  }

  StorageObject findByKey(TenantId tenantId, BucketId bucketId, string key) {
    return repos.objects.findByName(tenantId, bucketId, key);
  }

  // ── actions ────────────────────────────────────────────────────────────

  UsecaseResult archive(TenantId tenantId, StorageObjectId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref o) {
      ensureWritable(storage.requireBucket(tenantId, o.bucketId));
      ensureState(o.status == ObjectStatus.active, "Only active objects can be archived ('" ~ o.name ~ "' is "
        ~ enumText(o.status) ~ ")");
      o.storageClass = StorageClass.archive;
      o.status = ObjectStatus.archived;
    });
  }

  UsecaseResult restore(TenantId tenantId, StorageObjectId id, UserId actor) {
    return transition(tenantId, id, actor, "restored", (ref o) {
      auto bucket = storage.requireBucket(tenantId, o.bucketId);
      ensureWritable(bucket);
      ensureState(o.status == ObjectStatus.archived, "Object '" ~ o.name ~ "' is not archived");
      o.status = ObjectStatus.active;
      o.storageClass = bucket.storageClass == StorageClass.archive ? StorageClass.standard : bucket.storageClass;
    });
  }

  UsecaseResult hold(TenantId tenantId, StorageObjectId id, bool enabled, UserId actor) {
    return transition(tenantId, id, actor, enabled ? "placed on legal hold" : "released from legal hold", (ref o) {
      ensureState(o.legalHold != enabled, "Object '" ~ o.name ~ "' is " ~ (enabled ? "already" : "not")
        ~ " under legal hold");
      o.legalHold = enabled;
    });
  }

  UsecaseResult copy(TenantId tenantId, StorageObjectId id, BucketId targetBucket, string targetKey, UserId actor) {
    return guarded(() {
      auto source = require(tenantId, id);
      ensureReadable(source);
      auto content = storage.latestContent(tenantId, source.id);
      ensureState(!content.isNull, "Object '" ~ source.name ~ "' has no content");
      auto target = storage.requireBucket(tenantId, targetBucket.isEmpty ? source.bucketId : targetBucket);
      auto key = targetKey.strip.length > 0 ? targetKey.strip : source.name;
      ensureState(target.id != source.bucketId || key != source.name, "An object cannot be copied onto itself");
      auto copied = storage.write(target, key, ContentSource(null, content.blobId, content.size, content.etag),
        content.contentType, source.metadata, true, target.storageClass, false, actor);
      publish(copied, "copied");
      return succeeded(copied.id.value, "Object '%s/%s' copied to '%s/%s'".format(source.bucketName, source.name,
        target.name, key));
    });
  }
}
