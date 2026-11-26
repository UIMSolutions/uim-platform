/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port for grouping many writes (an evaluation run over all
/// bindings, cascading deletes, demo content) so that the storage persists
/// them at once — the file store writes its snapshot once per batch instead
/// of once per record. IDocumentStore itself is the shared port of
/// uim-platform:service.
module uim.platform.application_autoscaler.ports.storages.unit_of_work;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IAasUnitOfWork {
  /// Run work; writes inside are persisted when the outermost batch ends
  /// (also if work throws — the in-memory state is never rolled back).
  void batch(scope void delegate() @safe work);
}

/// Runs the work directly (stores that persist every write cheaply).
class ImmediateAasUnitOfWork : IAasUnitOfWork {
  void batch(scope void delegate() @safe work) {
    work();
  }
}
