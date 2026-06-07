/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.config;

import std.process : environment;


import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

struct SrvConfig {
  string host        = "0.0.0.0";
  ushort port        = 8097;
  string serviceName = "UIM Health FHIR Service";
  StorageBackend storage = StorageBackend.memory_;
  string dataPath    = "/app/data";
  string mongoUri    = "";
}

SrvConfig loadConfig() {
  SrvConfig config;

  auto hostEnv = environment.get("HEALTHFHIR_HOST", "");
  if (hostEnv.length > 0) config.host = hostEnv;

  auto portEnv = environment.get("HEALTHFHIR_PORT", "");
  if (portEnv.length > 0) {
    try config.port = portEnv.to!ushort;
    catch (Exception) {}
  }

  auto storageEnv = environment.get("HEALTHFHIR_STORAGE", "memory");
  switch (storageEnv) {
    case "files":   config.storage = StorageBackend.files_;   break;
    case "mongodb": config.storage = StorageBackend.mongodb_; break;
    default:        config.storage = StorageBackend.memory_;  break;
  }

  auto dataPathEnv = environment.get("HEALTHFHIR_DATA_PATH", "");
  if (dataPathEnv.length > 0) config.dataPath = dataPathEnv;

  auto mongoEnv = environment.get("HEALTHFHIR_MONGO_URI", "");
  if (mongoEnv.length > 0) config.mongoUri = mongoEnv;

  return config;
}
