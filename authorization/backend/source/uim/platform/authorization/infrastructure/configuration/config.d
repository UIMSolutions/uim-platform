/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → AUTHORIZATION_<KEY> environment variables (e.g. AUTHORIZATION_PORT,
///     AUTHORIZATION_DATA_FILE, AUTHORIZATION_MONGO_URI)
///   → Cloud Foundry (PORT, VCAP_SERVICES; user-provided service "authorization-config")
///   → explicit overrides (CLI/GUI options)
///
/// Legacy variables of the previous release are still honoured:
///   AUTHORIZATION_STORAGE_BACKEND (MEMORY|FILE|MONGODB) and AUTHORIZATION_FILE_PATH.
module uim.platform.authorization.infrastructure.configuration.config;

import std.process : environment;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "AUTHORIZATION";

struct AuthorizationConfig {
  string serviceName = "uim-authorization";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8117;
  string logLevel = "info";
  string storage = "memory"; /// memory | file | mongodb
  string dataFile = "data/authorization.json";
  string mongoUri = "mongodb://localhost:27017";
  string mongoDb = "uim_authorization";
  string mongoCollection = "documents";
  string defaultTenant = "default";
  string apiPath = "/api/v1";
  string restPath = "/rest/v1/authorization";
  string odataPath = "/odata/v4/authorization";
  string webPath = "/web";
  size_t maxPageSize = 200;
  bool requireAuthentication;
  string jwtSecret;
  string frontendDir = "../frontend";
  bool recordDecisions = true;
  int decisionRetentionDays = 90;
  uint decisionPruneMinutes; /// 0 = no background pruning
  string[] workerTenants = ["default"];
  bool seedBasePolicies = true;
  string seedTenantId = "default";
  string seedAppName = "authorization-management";
  string seedOrganizationId = "global";
  bool seedDemoData;

  Json raw; /// the merged document (incl. "services" from VCAP_SERVICES)
  string[] sources; /// where values came from (for diagnostics)

  StorageSettings storageSettings() const {
    return StorageSettings(storage, dataFile, mongoUri, mongoDb, mongoCollection);
  }

  /// Effective configuration with secrets masked.
  Json toMaskedJson() const @trusted {
    auto j = raw.clone;
    if ("jwtSecret" in j && j["jwtSecret"].type == Json.Type.string && j["jwtSecret"].get!string.length)
      j["jwtSecret"] = "***";
    if ("mongoUri" in j && j["mongoUri"].type == Json.Type.string && j["mongoUri"].get!string.canFind("@"))
      j["mongoUri"] = "***";
    if ("services" in j)
      j["services"] = "*** (" ~ j["services"].length.to!string ~ " bound services)";
    j["sources"] = textsJson(sources);
    return j;
  }
}

/// Built-in defaults as JSON (also the set of keys env vars may override).
Json defaultConfigJson() {
  AuthorizationConfig d;
  auto j = Json.emptyObject;
  static foreach (name; ["serviceName", "serviceVersion", "host", "port", "logLevel", "storage", "dataFile",
      "mongoUri", "mongoDb", "mongoCollection", "defaultTenant", "apiPath", "restPath", "odataPath", "webPath",
      "maxPageSize", "requireAuthentication", "jwtSecret", "frontendDir", "recordDecisions",
      "decisionRetentionDays", "decisionPruneMinutes", "seedBasePolicies", "seedTenantId", "seedAppName",
      "seedOrganizationId", "seedDemoData"])
    j[name] = __traits(getMember, d, name);
  j["workerTenants"] = textsJson(d.workerTenants);
  return j;
}

/// Load the layered configuration.
AuthorizationConfig loadAuthorizationConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);

  // legacy environment variables
  auto backend = environment.get("AUTHORIZATION_STORAGE_BACKEND", "");
  if (backend.length > 0 && environment.get("AUTHORIZATION_STORAGE", "").length == 0)
    j["storage"] = backend.toLower;
  auto legacyPath = environment.get("AUTHORIZATION_FILE_PATH", "");
  if (legacyPath.length > 0 && environment.get("AUTHORIZATION_DATA_FILE", "").length == 0)
    j["dataFile"] = legacyPath.endsWith(".json") ? legacyPath : buildPath(legacyPath, "authorization.json");

  // user-provided service "authorization-config" (Cloud Foundry)
  auto provided = serviceCredentials(j, "authorization-config");
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;

  foreach (k, v; overrides)
    j[k] = v;

  AuthorizationConfig c;
  c.raw = j;
  c.sources = ["defaults"];
  if (exists(buildPath(configDir, "default.json")))
    c.sources ~= buildPath(configDir, "default.json");
  c.sources ~= configEnvPrefix ~ "_* env";
  if (provided.isObject)
    c.sources ~= "VCAP_SERVICES";
  if (overrides.length)
    c.sources ~= "command line";

  static foreach (name; ["serviceName", "serviceVersion", "host", "logLevel", "storage", "dataFile", "mongoUri",
      "mongoDb", "mongoCollection", "defaultTenant", "jwtSecret", "frontendDir", "seedTenantId", "seedAppName",
      "seedOrganizationId"])
    __traits(getMember, c, name) = text(j, name, __traits(getMember, c, name));
  static foreach (name; ["apiPath", "restPath", "odataPath", "webPath"])
    __traits(getMember, c, name) = "/" ~ text(j, name, __traits(getMember, c, name)).strip("/");
  static foreach (name; ["requireAuthentication", "recordDecisions", "seedBasePolicies", "seedDemoData"])
    __traits(getMember, c, name) = flag(j, name, __traits(getMember, c, name));
  c.port = cast(ushort) number(j, "port", c.port);
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.decisionRetentionDays = cast(int) number(j, "decisionRetentionDays", c.decisionRetentionDays);
  c.decisionPruneMinutes = cast(uint) number(j, "decisionPruneMinutes", c.decisionPruneMinutes);
  c.storage = c.storage.toLower;
  if ("workerTenants" in j) {
    if (j["workerTenants"].type == Json.Type.array)
      c.workerTenants = textsField(j, "workerTenants");
    else if (j["workerTenants"].type == Json.Type.string)
      c.workerTenants = splitList(j["workerTenants"].get!string);
  }
  validateConfig(c);
  return c;
}

void validateConfig(const AuthorizationConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file", "mongodb", "mongo"].canFind(c.storage),
    "storage must be 'memory', 'file' or 'mongodb', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  string[] paths = [c.apiPath.idup, c.restPath.idup, c.odataPath.idup, c.webPath.idup];
  enforce(paths.sort.uniq.walkLength == paths.length, "apiPath, restPath, odataPath and webPath must differ");
}

private string text(Json j, string key, string fallback) {
  return key in j && j[key].type == Json.Type.string ? j[key].get!string : fallback;
}

private long number(Json j, string key, long fallback) @trusted {
  if (key !in j)
    return fallback;
  if (j[key].type == Json.Type.int_)
    return j[key].get!long;
  if (j[key].type == Json.Type.float_)
    return cast(long) j[key].get!double;
  if (j[key].type == Json.Type.string)
    try
      return j[key].get!string.to!long;
    catch (Exception)
      return fallback;
  return fallback;
}

private bool flag(Json j, string key, bool fallback) {
  if (key !in j)
    return fallback;
  if (j[key].type == Json.Type.bool_)
    return j[key].get!bool;
  if (j[key].type == Json.Type.string)
    return ["true", "1", "yes", "on"].canFind(j[key].get!string.toLower);
  return fallback;
}

///
unittest {
  mixin(ShowTest!("AuthorizationConfig"));

  Json[string] o;
  o["storage"] = "MEMORY";
  o["port"] = 9001;
  o["odataPath"] = "odata/v4/ams/";
  o["workerTenants"] = "a, b";
  o["recordDecisions"] = "false";
  auto c = loadAuthorizationConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/ams");
  assert(c.workerTenants == ["a", "b"] && !c.recordDecisions);
  assert(c.toMaskedJson()["port"].get!long == 9001);
}
