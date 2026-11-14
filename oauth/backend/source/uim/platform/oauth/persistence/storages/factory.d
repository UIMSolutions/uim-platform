/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Selects the IDocumentStore implementation.
///   memory  in-process, lost on exit (tests, ephemeral demos)
///   file    one JSON snapshot shared by server, CLI and GUI (development, single node)
module uim.platform.oauth.persistence.storages.factory;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

IDocumentStore createDocumentStore(string kind, string dataFile) {
  switch (kind.toLower) {
  case "memory":
    return new MemoryDocumentStore;
  case "file":
    if (dataFile.strip.length == 0)
      throw new Exception("storage 'file' needs a dataFile");
    return new FileDocumentStore(dataFile);
  default:
    throw new Exception("Unknown storage '" ~ kind ~ "' (allowed: memory, file)");
  }
}
