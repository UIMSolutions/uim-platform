module uim.platform.analytics.infrastructure.config;

import std.conv : to;
import std.process : environment;
import uim.platform.analytics.domain.types;

struct AppConfig {
  string host = "0.0.0.0";
  ushort port = 8112;
  string serviceName = "UIM Analytics Service";
  StorageBackend storage = StorageBackend.memory_;
  string dataPath = "/data/analytics";
  string mongoUri = "";
  string mongoDb = "analytics";
}

AppConfig loadConfig() {
  AppConfig cfg;

  auto host = environment.get("ANALYTICS_HOST", "");
  if (host.length > 0) cfg.host = host;

  auto port = environment.get("ANALYTICS_PORT", "");
  if (port.length > 0) cfg.port = port.to!ushort;

  auto storage = environment.get("ANALYTICS_STORAGE", "");
  switch (storage) {
    case "files":
      cfg.storage = StorageBackend.files_;
      break;
    case "mongodb":
      cfg.storage = StorageBackend.mongodb_;
      break;
    default:
      cfg.storage = StorageBackend.memory_;
      break;
  }

  auto dataPath = environment.get("ANALYTICS_DATA_PATH", "");
  if (dataPath.length > 0) cfg.dataPath = dataPath;

  auto mongoUri = environment.get("ANALYTICS_MONGO_URI", "");
  if (mongoUri.length > 0) cfg.mongoUri = mongoUri;

  auto mongoDb = environment.get("ANALYTICS_MONGO_DB", "");
  if (mongoDb.length > 0) cfg.mongoDb = mongoDb;

  return cfg;
}
