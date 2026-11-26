/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Selects the document store implementation.
///   memory  in-process, lost on exit (tests, ephemeral demos)
///   file    one JSON snapshot shared by server, CLI and GUI (development, single node)
module uim.platform.application_autoscaler.persistence.storages.factory;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// A document store that is also the unit of work for batched writes.
struct StorageSetup {
  IDocumentStore store;
  IAasUnitOfWork unitOfWork;
}

StorageSetup createStorage(string kind, string dataFile) {
  switch (kind.toLower) {
  case "memory":
    auto m = new BatchingMemoryDocumentStore;
    return StorageSetup(m, m);
  case "file":
    if (dataFile.strip.length == 0)
      throw new Exception("storage 'file' needs a dataFile");
    auto f = new BatchingFileDocumentStore(dataFile);
    return StorageSetup(f, f);
  default:
    throw new Exception("Unknown storage '" ~ kind ~ "' (allowed: memory, file)");
  }
}
