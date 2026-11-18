/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.storage_object;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// An object (key) of a bucket. The content lives in its versions
/// (ObjectVersion → blob); the object mirrors the latest version.
struct StorageObject {
  mixin TenantEntity!StorageObjectId;

  BucketId bucketId;
  string bucketName;
  string name; /// object key, e.g. "images/2026/photo.jpg"
  string contentType = "application/octet-stream";
  long size; /// bytes of the latest version
  string etag; /// MD5 of the latest content (hex, S3 style)
  MetadataEntry[] metadata;
  StorageClass storageClass = StorageClass.standard;
  ObjectStatus status = ObjectStatus.active;
  bool legalHold; /// no overwrite, delete or expiry while set

  // Versions (maintained by the object operations)
  int currentVersion; /// version number of the latest version
  int versionCount; /// stored versions incl. delete markers
  ObjectVersionId currentVersionId;
}

/// The folder part of a key ("a/b/c.txt" → "a/b/"; "c.txt" → "").
string keyFolder(string key) pure {
  import std.string : lastIndexOf;

  auto slash = key.lastIndexOf('/');
  return slash < 0 ? "" : key[0 .. slash + 1];
}

///
unittest {
  assert(keyFolder("a/b/c.txt") == "a/b/");
  assert(keyFolder("c.txt") == "");
}
