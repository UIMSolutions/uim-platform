/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → DR_<KEY> environment variables (e.g. DR_PORT, DR_STORAGE, DR_JWT_SECRET)
///     (the former DATA_RETENTION_HOST / DATA_RETENTION_PORT still work)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "data-retention-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.data_retention.infrastructure.configuration.config;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "DR";

/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "data-retention-config";

struct DrConfig {
  string serviceName = "uim-data-retention";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8112;
  string storage = "memory"; /// memory | file
  string dataFile = "data/data-retention.json";
  string defaultTenant = "default";
  string apiPath = "/api/v1"; /// REST: <apiPath>/data-retention/…
  string odataPath = "/odata/v4/data-retention";
  size_t maxPageSize = 200;
  size_t maxRequestBytes = 4 * 1024 * 1024;
  string authMode = "open"; /// open | jwt (built-in login); an XSUAA binding always wins
  string jwtSecret; /// HS256 secret of the built-in login (>= 32 characters; "" = random per start)
  long tokenTtlSeconds = 3600;
  string adminUser = "admin"; /// created on first start in jwt mode
  string adminPassword; /// "" = generated and logged once
  uint passwordIterations = 120_000; /// PBKDF2 rounds
  string frontendDir = "../frontend";
  uint workerIntervalSeconds = 5; /// deletion requests and due archiving jobs; 0 = process on creation
  uint endOfPurposeCheckSeconds = 0; /// periodic end-of-purpose check by the worker; 0 = off
  string[] workerTenants = ["default"];
  DrPolicy policy;

  Json raw; /// the merged document (incl. "services" from VCAP_SERVICES)
  string[] sources; /// where values came from (for diagnostics)

  /// Effective configuration with secrets masked.
  Json toMaskedJson() @trusted {
    auto j = raw.clone;
    foreach (secret; ["jwtSecret", "adminPassword"])
      if (secret in j && j[secret].type == Json.Type.string && j[secret].get!string.length)
        j[secret] = "***";
    if ("services" in j)
      j["services"] = "*** (" ~ j["services"].length.to!string ~ " bound services)";
    return j;
  }
}

/// Built-in defaults as JSON (also the set of keys env vars may override).
Json defaultConfigJson() {
  DrConfig d;
  auto j = Json.emptyObject;
  j["serviceName"] = d.serviceName;
  j["serviceVersion"] = d.serviceVersion;
  j["host"] = d.host;
  j["port"] = d.port;
  j["storage"] = d.storage;
  j["dataFile"] = d.dataFile;
  j["defaultTenant"] = d.defaultTenant;
  j["apiPath"] = d.apiPath;
  j["odataPath"] = d.odataPath;
  j["maxPageSize"] = d.maxPageSize;
  j["maxRequestBytes"] = d.maxRequestBytes;
  j["authMode"] = d.authMode;
  j["requireAuthentication"] = false;
  j["jwtSecret"] = "";
  j["tokenTtlSeconds"] = d.tokenTtlSeconds;
  j["adminUser"] = d.adminUser;
  j["adminPassword"] = "";
  j["passwordIterations"] = d.passwordIterations;
  j["maxFailedLogins"] = d.policy.maxFailedLogins;
  j["lockSeconds"] = d.policy.lockSeconds;
  j["minPasswordLength"] = d.policy.minPasswordLength;
  j["frontendDir"] = d.frontendDir;
  j["workerIntervalSeconds"] = d.workerIntervalSeconds;
  j["endOfPurposeCheckSeconds"] = d.endOfPurposeCheckSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.workerTenants)
    tenants ~= Json(t);
  j["workerTenants"] = tenants;
  return j;
}

/// Load the layered configuration.
DrConfig loadDrConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;
  import std.process : environment;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  // compatibility with the variables of the first service generation
  if (environment.get("DR_HOST", "").length == 0 && environment.get("DATA_RETENTION_HOST", "").length)
    j["host"] = environment.get("DATA_RETENTION_HOST");
  if (environment.get("DR_PORT", "").length == 0 && environment.get("PORT", "").length == 0) {
    try
      if (environment.get("DATA_RETENTION_PORT", "").length)
        j["port"] = environment.get("DATA_RETENTION_PORT").to!ushort;
    catch (Exception) {
    }
  }
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  DrConfig c;
  c.raw = j;
  c.sources = ["defaults"];
  if (exists(buildPath(configDir, "default.json")))
    c.sources ~= buildPath(configDir, "default.json");
  c.sources ~= configEnvPrefix ~ "_* env";
  if (provided.isObject)
    c.sources ~= "VCAP_SERVICES " ~ configServiceName;
  if (overrides.length)
    c.sources ~= "command line";

  c.serviceName = text(j, "serviceName", c.serviceName);
  c.serviceVersion = text(j, "serviceVersion", c.serviceVersion);
  c.host = text(j, "host", c.host);
  c.port = cast(ushort) number(j, "port", c.port);
  c.storage = text(j, "storage", c.storage).strip.toLower;
  c.dataFile = text(j, "dataFile", c.dataFile);
  c.defaultTenant = text(j, "defaultTenant", c.defaultTenant);
  c.apiPath = "/" ~ text(j, "apiPath", c.apiPath).strip("/");
  c.odataPath = "/" ~ text(j, "odataPath", c.odataPath).strip("/");
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.maxRequestBytes = cast(size_t) number(j, "maxRequestBytes", c.maxRequestBytes);
  c.authMode = text(j, "authMode", c.authMode).strip.toLower;
  if (flag(j, "requireAuthentication", false)) // compatibility: requireAuthentication = built-in JWT
    c.authMode = "jwt";
  c.jwtSecret = text(j, "jwtSecret", "");
  c.tokenTtlSeconds = number(j, "tokenTtlSeconds", c.tokenTtlSeconds);
  c.adminUser = text(j, "adminUser", c.adminUser);
  c.adminPassword = text(j, "adminPassword", "");
  c.passwordIterations = cast(uint) number(j, "passwordIterations", c.passwordIterations);
  c.policy.maxFailedLogins = cast(int) number(j, "maxFailedLogins", c.policy.maxFailedLogins);
  c.policy.lockSeconds = number(j, "lockSeconds", c.policy.lockSeconds);
  c.policy.minPasswordLength = cast(size_t) number(j, "minPasswordLength", c.policy.minPasswordLength);
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.workerIntervalSeconds = cast(uint) number(j, "workerIntervalSeconds", c.workerIntervalSeconds);
  c.endOfPurposeCheckSeconds = cast(uint) number(j, "endOfPurposeCheckSeconds", c.endOfPurposeCheckSeconds);
  if ("workerTenants" in j && j["workerTenants"].type == Json.Type.array) {
    c.workerTenants = null;
    foreach (t; j["workerTenants"])
      if (t.type == Json.Type.string)
        c.workerTenants ~= t.get!string;
  } else if ("workerTenants" in j && j["workerTenants"].type == Json.Type.string) // env: "a,b"
    c.workerTenants = j["workerTenants"].get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  c.policy.processRequestsImmediately = c.workerIntervalSeconds == 0;
  c.policy.runJobsImmediately = c.workerIntervalSeconds == 0;
  validateConfig(c);
  return c;
}

void validateConfig(const DrConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.apiPath != c.odataPath, "apiPath and odataPath must differ");
  enforce(c.maxRequestBytes >= 1024, "maxRequestBytes must be at least 1024");
  enforce(c.workerIntervalSeconds <= 86_400, "workerIntervalSeconds must be between 0 and 86400");
  enforce(c.endOfPurposeCheckSeconds == 0 || c.endOfPurposeCheckSeconds >= 60,
    "endOfPurposeCheckSeconds must be 0 (off) or at least 60");
  enforce(["open", "jwt"].canFind(c.authMode), "authMode must be 'open' or 'jwt', not '" ~ c.authMode ~ "'");
  enforce(c.jwtSecret.length == 0 || c.jwtSecret.length >= 32, "jwtSecret must have at least 32 characters");
  enforce(c.tokenTtlSeconds >= 60 && c.tokenTtlSeconds <= 7 * 86_400, "tokenTtlSeconds must be between 60 and 604800");
  enforce(c.passwordIterations >= 1000, "passwordIterations must be at least 1000");
  enforce(isValidId(c.adminUser), "adminUser '" ~ c.adminUser ~ "' is not a valid user name");
  enforce(c.policy.minPasswordLength >= 8, "minPasswordLength must be at least 8");
}

private string text(Json j, string key, string fallback) {
  return key in j && j[key].type == Json.Type.string ? j[key].get!string : fallback;
}

private long number(Json j, string key, long fallback) {
  if (key !in j)
    return fallback;
  if (j[key].type == Json.Type.int_)
    return j[key].get!long;
  if (j[key].type == Json.Type.float_)
    return cast(long) j[key].get!double;
  return fallback;
}

private bool flag(Json j, string key, bool fallback) {
  return key in j && j[key].type == Json.Type.bool_ ? j[key].get!bool : fallback;
}

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["port"] = 9001;
  o["odataPath"] = "odata/v4/dr/";
  o["workerIntervalSeconds"] = 0;
  auto c = loadDrConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/dr");
  assert(c.policy.processRequestsImmediately && c.policy.runJobsImmediately && c.authMode == "open");
  o["requireAuthentication"] = true;
  assert(loadDrConfig(o, "/nonexistent").authMode == "jwt");
  o.remove("requireAuthentication");
  assert(loadDrConfig(o, "/nonexistent").toMaskedJson()["jwtSecret"].get!string == "");

  o["storage"] = "tape";
  bool failed;
  try
    loadDrConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
