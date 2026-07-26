module uim.platform.authorization.infrastructure.config;

import std.conv : ConvException, to;
import std.process : environment;
import std.string : toLower;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct SrvConfig {
  string host = "0.0.0.0";
  ushort port = 8117;
  string serviceName = "Authorization Management Service";
  string storageBackend = "MEMORY";
  string fileStoragePath = "/data/authorization";
  string mongoUri = "mongodb://localhost:27017";
  string mongoDb = "uim_authorization";
  string mongoCollection = "tenant_state";

  bool seedBasePoliciesOnStartup = true;
  string seedTenantId = "default";
  string seedApplicationName = "authorization-management";
  string seedApplicationOrganizationId = "global";
}

private bool parseBoolEnv(string value, bool fallback) {
  if (value.length == 0) return fallback;
  auto v = toLower(value);
  return v == "1" || v == "true" || v == "yes" || v == "on";
}

SrvConfig loadConfig() {
  SrvConfig cfg;

  auto host = environment.get("AUTHORIZATION_HOST", "");
  if (host.length) cfg.host = host;

  auto portStr = environment.get("AUTHORIZATION_PORT", "");
  if (portStr.length) {
    try cfg.port = portStr.to!ushort;
    catch (ConvException) {}
  }

  auto name = environment.get("AUTHORIZATION_SERVICE_NAME", "");
  if (name.length) cfg.serviceName = name;

  auto backend = environment.get("AUTHORIZATION_STORAGE_BACKEND", "");
  if (backend.length) cfg.storageBackend = backend;

  auto filePath = environment.get("AUTHORIZATION_FILE_PATH", "");
  if (filePath.length) cfg.fileStoragePath = filePath;

  auto mongoUri = environment.get("AUTHORIZATION_MONGO_URI", "");
  if (mongoUri.length) cfg.mongoUri = mongoUri;

  auto mongoDb = environment.get("AUTHORIZATION_MONGO_DB", "");
  if (mongoDb.length) cfg.mongoDb = mongoDb;

  auto mongoCollection = environment.get("AUTHORIZATION_MONGO_COLLECTION", "");
  if (mongoCollection.length) cfg.mongoCollection = mongoCollection;

  cfg.seedBasePoliciesOnStartup = parseBoolEnv(
    environment.get("AUTHORIZATION_SEED_BASE_POLICIES", ""),
    cfg.seedBasePoliciesOnStartup
  );

  auto seedTenant = environment.get("AUTHORIZATION_SEED_TENANT_ID", "");
  if (seedTenant.length) cfg.seedTenantId = seedTenant;

  auto seedAppName = environment.get("AUTHORIZATION_SEED_APP_NAME", "");
  if (seedAppName.length) cfg.seedApplicationName = seedAppName;

  auto seedOrg = environment.get("AUTHORIZATION_SEED_ORGANIZATION_ID", "");
  if (seedOrg.length) cfg.seedApplicationOrganizationId = seedOrg;

  return cfg;
}
