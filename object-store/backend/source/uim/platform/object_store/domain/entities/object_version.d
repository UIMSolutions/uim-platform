/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.object_version;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// One immutable version of an object, or a delete marker. Versions are
/// created by writing objects, never directly.
struct ObjectVersion {
  mixin TenantEntity!ObjectVersionId;

  StorageObjectId objectId;
  BucketId bucketId;
  string objectKey;
  string name; /// "v<versionNumber>"
  int versionNumber; /// 1, 2, 3 … per object
  long size;
  string etag;
  string contentType;
  string blobId; /// content address (SHA-256) in the blob storage; "" for delete markers
  bool isLatest;
  bool isDeleteMarker;
}

/// "v3".
string versionName(int versionNumber) {
  import std.conv : to;

  return "v" ~ versionNumber.to!string;
}
