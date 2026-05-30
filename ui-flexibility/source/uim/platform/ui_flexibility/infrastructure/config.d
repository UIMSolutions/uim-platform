/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.config;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

struct SrvConfig {
  string host        = "0.0.0.0";
  ushort port        = 8098;
  string serviceName = "UIM UI Flexibility Service";
  StorageBackend storage = StorageBackend.memory_;
  string dataPath    = "/data/ui-flexibility";
  string mongoUri    = "";
}

SrvConfig loadConfig() @trusted {
  import std.process : environment;
  

  SrvConfig c;
  auto host = environment.get("UIFLEXIBILITY_HOST", "");
  if (host.length > 0) c.host = host;

  auto port = environment.get("UIFLEXIBILITY_PORT", "");
  if (port.length > 0) c.port = port.to!ushort;

  auto storage = environment.get("UIFLEXIBILITY_STORAGE", "");
  switch (storage) {
    case "files":   c.storage = StorageBackend.files_;   break;
    case "mongodb": c.storage = StorageBackend.mongodb_; break;
    default:        c.storage = StorageBackend.memory_;  break;
  }

  auto dataPath = environment.get("UIFLEXIBILITY_DATA_PATH", "");
  if (dataPath.length > 0) c.dataPath = dataPath;

  auto mongoUri = environment.get("UIFLEXIBILITY_MONGO_URI", "");
  if (mongoUri.length > 0) c.mongoUri = mongoUri;

  return c;
}
