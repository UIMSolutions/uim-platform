/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.storages.snapshot;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: low-level document storage used by the persistence layer to keep
/// one JSON snapshot per collection (e.g. "functions"). Shared by server, CLI and GUI.
interface ISnapshotStorage {
  /// Load the snapshot of a collection. Returns an empty array if none exists.
  Json load(string collection);

  /// Persist the full snapshot of a collection.
  void store(string collection, Json snapshot);

  /// A monotonic change marker (e.g. file mtime) — 0 if the collection does not exist.
  long revision(string collection);
}
