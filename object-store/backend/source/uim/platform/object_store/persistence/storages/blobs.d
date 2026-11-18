/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Blob storages (object content) implementing IBlobStorage.
module uim.platform.object_store.persistence.storages.blobs;

import std.file : exists, mkdirRecurse, read, rename, write, remove;
import std.path : buildPath;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Tenant ids and blob ids become path segments — only allow safe characters.
private string safeSegment(string value, string what) {
  validate(value.length > 0 && value.length <= 128
      && value.all!(c => (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')
        || c == '-' || c == '_' || c == '.') && value != "." && value != "..",
    "Invalid " ~ what ~ " '" ~ value ~ "'");
  return value;
}

/// Content addressed files: <root>/<tenant>/<id[0..2]>/<id>. Writes go to a
/// temp file first and are renamed atomically, so the server, the CLI and the
/// GUI can share the directory.
class FileBlobStorage : IBlobStorage {
  protected string root;

  this(string root) {
    this.root = root;
    if (!root.exists)
      (() @trusted => mkdirRecurse(root))();
  }

  protected string pathOf(TenantId tenantId, string blobId) {
    auto id = safeSegment(blobId, "blob id");
    validate(id.length >= 3, "Invalid blob id '" ~ id ~ "'");
    return buildPath(root, safeSegment(tenantId.value, "tenant id"), id[0 .. 2], id);
  }

  string put(TenantId tenantId, const(ubyte)[] data) {
    auto id = contentAddress(data);
    auto path = pathOf(tenantId, id);
    if (path.exists)
      return id;
    () @trusted {
      import std.path : dirName;

      mkdirRecurse(path.dirName);
      auto tmp = path ~ ".tmp";
      write(tmp, data);
      rename(tmp, path);
    }();
    return id;
  }

  const(ubyte)[] get(TenantId tenantId, string blobId) {
    auto path = pathOf(tenantId, blobId);
    if (!path.exists)
      throw new ObjectStoreNotFoundException("Content " ~ blobId ~ " is missing in the blob storage");
    return (() @trusted => cast(const(ubyte)[]) read(path))();
  }

  bool exists(TenantId tenantId, string blobId) {
    return pathOf(tenantId, blobId).exists;
  }

  void remove(TenantId tenantId, string blobId) {
    auto path = pathOf(tenantId, blobId);
    if (path.exists)
      (() @trusted => std.file.remove(path))();
  }
}

/// Volatile blob storage (tests, "memory" storage mode).
class MemoryBlobStorage : IBlobStorage {
  protected const(ubyte)[][string][string] blobs;

  string put(TenantId tenantId, const(ubyte)[] data) {
    auto id = contentAddress(data);
    blobs[tenantId.value][id] = data.idup;
    return id;
  }

  const(ubyte)[] get(TenantId tenantId, string blobId) {
    if (auto byTenant = tenantId.value in blobs)
      if (auto data = blobId in *byTenant)
        return *data;
    throw new ObjectStoreNotFoundException("Content " ~ blobId ~ " is missing in the blob storage");
  }

  bool exists(TenantId tenantId, string blobId) {
    if (auto byTenant = tenantId.value in blobs)
      return (blobId in *byTenant) !is null;
    return false;
  }

  void remove(TenantId tenantId, string blobId) {
    if (auto byTenant = tenantId.value in blobs)
      (*byTenant).remove(blobId);
  }

  size_t count(TenantId tenantId) {
    if (auto byTenant = tenantId.value in blobs)
      return byTenant.length;
    return 0;
  }
}

///
unittest {
  mixin(ShowTest!("BlobStorage"));

  import std.file : tempDir, rmdirRecurse;

  auto dir = buildPath(tempDir, "uim-object-store-blobs-" ~ newSalt()[0 .. 8]);
  scope (exit)
    (() @trusted => rmdirRecurse(dir))();

  foreach (IBlobStorage s; [cast(IBlobStorage) new MemoryBlobStorage(), new FileBlobStorage(dir)]) {
    auto t = TenantId("t1");
    auto id = s.put(t, cast(const(ubyte)[]) "hello");
    assert(id == contentAddress(cast(const(ubyte)[]) "hello"));
    assert(s.put(t, cast(const(ubyte)[]) "hello") == id); // idempotent
    assert(bytesToText(s.get(t, id)) == "hello");
    assert(s.exists(t, id) && !s.exists(TenantId("t2"), id));
    s.remove(t, id);
    assert(!s.exists(t, id));
    bool missing;
    try s.get(t, id);
    catch (ObjectStoreNotFoundException) missing = true;
    assert(missing);
  }

  bool rejected;
  try new FileBlobStorage(dir).put(TenantId("../etc"), cast(const(ubyte)[]) "x");
  catch (ObjectStoreValidationException) rejected = true;
  assert(rejected);
}
