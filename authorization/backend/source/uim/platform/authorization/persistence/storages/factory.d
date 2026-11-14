/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Selects the IDocumentStore implementation.
///   memory   in-process, lost on exit (tests, ephemeral demos)
///   file     one JSON snapshot shared by server, CLI and GUI (development, single node)
///   mongodb  MongoDB collection (production, several replicas)
module uim.platform.authorization.persistence.storages.factory;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct StorageSettings {
  string kind = "memory";
  string dataFile = "data/authorization.json";
  string mongoUri = "mongodb://localhost:27017";
  string mongoDb = "uim_authorization";
  string mongoCollection = "documents";
}

IDocumentStore createDocumentStore(StorageSettings s) {
  switch (s.kind.strip.toLower) {
  case "memory":
    return new MemoryDocumentStore;
  case "file":
    if (s.dataFile.strip.length == 0)
      throw new Exception("storage 'file' needs a dataFile");
    return new FileDocumentStore(s.dataFile);
  case "mongodb", "mongo":
    return new MongoDocumentStore(s.mongoUri, s.mongoDb, s.mongoCollection);
  default:
    throw new Exception("Unknown storage '" ~ s.kind ~ "' (allowed: memory, file, mongodb)");
  }
}
