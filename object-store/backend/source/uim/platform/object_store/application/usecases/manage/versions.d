/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.application.usecases.manage.versions;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Interactor: object versions. Versions are immutable and created by
/// writing objects; they can be deleted permanently or promoted to the latest.
class ManageVersionsUseCase
  : ResourceUseCase!(ObjectVersion, ObjectVersionId, CreateVersionRequest, UpdateVersionRequest),
  IManageVersionsUseCase {

  protected ObjectStorageService storage;

  this(ObjectStoreRepositories repos, EventRecorder events, ObjectStorageService storage) {
    super(repos, repos.versions, events, "Version", "objectstore.version");
    this.storage = storage;
  }

  override protected ObjectVersion build(CreateVersionRequest r) {
    throw new ObjectStoreException("Versions are created by writing objects", 405);
  }

  override protected void apply(ref ObjectVersion v, VersionSpec spec) {
    throw new ObjectStoreException("Versions are immutable", 405);
  }

  override UsecaseResult remove(TenantId tenantId, ObjectVersionId id, UserId actor) {
    return guarded(() {
      auto v = require(tenantId, id);
      storage.purgeVersion(v, actor);
      publish(v, "deleted");
      return succeeded(v.id.value, "Version %d of '%s' deleted permanently".format(v.versionNumber, v.objectKey));
    });
  }

  ObjectVersion[] listByObject(TenantId tenantId, StorageObjectId objectId) {
    return repos.versions.findByObject(tenantId, objectId);
  }

  UsecaseResult promote(TenantId tenantId, ObjectVersionId id, UserId actor) {
    return guarded(() {
      auto v = require(tenantId, id);
      ensureState(!v.isDeleteMarker, "Delete markers cannot be promoted — delete the marker instead");
      ensureState(!v.isLatest, "Version %d of '%s' is already the latest".format(v.versionNumber, v.objectKey));
      auto obj = storage.requireObject(tenantId, v.objectId);
      auto bucket = storage.requireBucket(tenantId, obj.bucketId);
      auto updated = storage.write(bucket, obj.name, ContentSource(null, v.blobId, v.size, v.etag), v.contentType,
        obj.metadata, false, obj.storageClass, true, actor);
      publish(v, "promoted");
      return succeeded(updated.currentVersionId.value, "Version %d of '%s' promoted to version %d".format(
        v.versionNumber, v.objectKey, updated.currentVersion));
    });
  }
}
