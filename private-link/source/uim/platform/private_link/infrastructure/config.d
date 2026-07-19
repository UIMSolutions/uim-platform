/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.config;

import std.process : environment;
import uim.platform.private_link;
mixin(ShowModule!());

@safe:
/// Runtime configuration for the Private Link service.
struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8087;
  string serviceName = "Private Link Service";
  /// MongoDB connection URI (empty = use in-memory storage).
  string mongoUri = "";
  /// Directory path for file-based storage (empty = use in-memory).
  string dataDir = "";
}

/// Load configuration from environment variables.
/// PRIVLINK_HOST, PRIVLINK_PORT, PRIVLINK_MONGO_URI, PRIVLINK_DATA_DIR
SrvConfig loadConfig() {
  SrvConfig config;

  auto host = environment.get("PRIVLINK_HOST", "");
  if (host.length > 0)
    config.host = host;

  auto portStr = environment.get("PRIVLINK_PORT", "");
  if (portStr.length > 0) {
    try
      config.port = portStr.to!ushort;
    catch (Exception) {
    }
  }

  auto mongoUri = environment.get("PRIVLINK_MONGO_URI", "");
  if (mongoUri.length > 0)
    config.mongoUri = mongoUri;

  auto dataDir = environment.get("PRIVLINK_DATA_DIR", "");
  if (dataDir.length > 0)
    config.dataDir = dataDir;

  return config;
}
