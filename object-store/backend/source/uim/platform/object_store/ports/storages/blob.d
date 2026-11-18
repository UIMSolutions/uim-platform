/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.ports.storages.blob;

import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Driven port: content addressed storage of object content, per tenant.
/// Identical content is stored once (the blob id is its SHA-256), so copies
/// and promoted versions cost no extra space. Implementations: local files,
/// memory; a hyperscaler adapter (S3, Azure Blob, GCS) fits the same port.
interface IBlobStorage {
  /// Store `data` and return its blob id (idempotent).
  string put(TenantId tenantId, const(ubyte)[] data);

  /// The content of a blob (throws ObjectStoreNotFoundException if missing).
  const(ubyte)[] get(TenantId tenantId, string blobId);

  bool exists(TenantId tenantId, string blobId);

  /// Delete a blob (no-op if missing).
  void remove(TenantId tenantId, string blobId);
}
