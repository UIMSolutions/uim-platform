/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Document stores with batch support (IDqUnitOfWork). The file store of
/// uim-platform:service rewrites its whole snapshot on every write; inside
/// a batch, writes go to memory only and the snapshot is written once at
/// the end — a bulk import of n records costs one file write, not n.
module uim.platform.data_quality.persistence.storages.batching;

import uim.platform.data_quality;
import uim.platform.service.persistence.storages.documents.memory : MemoryDocumentStore;
import uim.platform.service.persistence.storages.documents.file : FileDocumentStore;

mixin(ShowModule!());

@safe:

/// In-memory store; batches are free.
class BatchingMemoryDocumentStore : MemoryDocumentStore, IDqUnitOfWork {
  void batch(scope void delegate() @safe work) {
    work();
  }
}

/// JSON snapshot file store that defers the snapshot write inside batches.
class BatchingFileDocumentStore : FileDocumentStore, IDqUnitOfWork {
  protected size_t depth;
  protected bool dirty;
  size_t flushes; /// snapshot writes (diagnostics, tests)

  this(string path) {
    super(path);
  }

  void batch(scope void delegate() @safe work) {
    if (depth == 0)
      reload();
    depth++;
    scope (exit) {
      depth--;
      if (depth == 0 && dirty) {
        dirty = false;
        flushes++;
        flush();
      }
    }
    work();
  }

  override void put(string collection, string tenantId, string key, Json document) {
    if (depth == 0) {
      flushes++;
      super.put(collection, tenantId, key, document);
      return;
    }
    MemoryDocumentStore.put(collection, tenantId, key, document);
    dirty = true;
  }

  override bool remove(string collection, string tenantId, string key) {
    if (depth == 0) {
      auto removed = super.remove(collection, tenantId, key);
      if (removed)
        flushes++;
      return removed;
    }
    auto removed = MemoryDocumentStore.remove(collection, tenantId, key);
    if (removed)
      dirty = true;
    return removed;
  }

  // inside a batch the memory state is authoritative (no reload from disk)
  override Json[] all(string collection, string tenantId) {
    return depth > 0 ? MemoryDocumentStore.all(collection, tenantId) : super.all(collection, tenantId);
  }

  override Json get(string collection, string tenantId, string key) {
    return depth > 0 ? MemoryDocumentStore.get(collection, tenantId, key) : super.get(collection, tenantId, key);
  }

  override size_t count(string collection, string tenantId) {
    return depth > 0 ? MemoryDocumentStore.count(collection, tenantId) : super.count(collection, tenantId);
  }
}

///
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-dq-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto store = new BatchingFileDocumentStore(file);
  store.batch(() {
    foreach (i; 0 .. 50)
      store.put("c", "t", i.to!string, Json(["i": Json(i)]));
    store.remove("c", "t", "0");
  });
  assert(store.flushes == 1 && store.count("c", "t") == 49);
  auto other = new BatchingFileDocumentStore(file); // e.g. the CLI next to the server
  assert(other.count("c", "t") == 49);
  store.put("c", "t", "x", Json.emptyObject);
  assert(store.flushes == 2 && other.count("c", "t") == 50);
}
