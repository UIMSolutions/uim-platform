/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.infrastructure.config;
import std.process : environment;
import std.conv    : to;

@safe:

struct AppConfig {
  string host;
  ushort port;
  string serviceName;
  string storageBackend;
  string fileStoragePath;
  string mongoUri;
  string mongoDb;
}

AppConfig loadConfig() {
  AppConfig cfg;
  cfg.host           = environment.get("MARKET_REFINITIV_HOST", "0.0.0.0");
  cfg.port           = environment.get("MARKET_REFINITIV_PORT", "8098").to!ushort;
  cfg.serviceName    = environment.get("MARKET_REFINITIV_SERVICE_NAME", "uim-market-refinitiv-platform-service");
  cfg.storageBackend = environment.get("MARKET_REFINITIV_STORAGE_BACKEND", "MEMORY");
  cfg.fileStoragePath = environment.get("MARKET_REFINITIV_FILE_PATH", "/data/market-refinitiv");
  cfg.mongoUri       = environment.get("MARKET_REFINITIV_MONGO_URI", "mongodb://localhost:27017");
  cfg.mongoDb        = environment.get("MARKET_REFINITIV_MONGO_DB", "market_refinitiv");
  return cfg;
}
