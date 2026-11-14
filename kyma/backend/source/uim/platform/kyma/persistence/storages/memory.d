/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.storages.memory;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Volatile snapshot storage (tests, "memory" storage mode).
class MemorySnapshotStorage : ISnapshotStorage {
  protected Json[string] _snapshots;
  protected long[string] _revisions;

  Json load(string collection) {
    if (auto s = collection in _snapshots)
      return *s;
    return Json.emptyArray;
  }

  void store(string collection, Json snapshot) {
    _snapshots[collection] = snapshot;
    _revisions[collection] = _revisions.get(collection, 0) + 1;
  }

  long revision(string collection) {
    return _revisions.get(collection, 0);
  }
}
