/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → AILP_<KEY> environment variables (e.g. AILP_PORT, AILP_STORAGE,
///     AILP_JWT_SECRET, AILP_AUTH_MODE)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "ai-launchpad-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.ai_launchpad.infrastructure.configuration.config;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "AILP";
/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "ai-launchpad-config";

struct AilpConfig {
  string serviceName = "uim-ai-launchpad";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8097;
  string storage = "memory"; /// memory | file
  string dataFile = "data/ai-launchpad.json";
  string defaultTenant = "default";
  string apiPath = "/api/v1"; /// REST: <apiPath>/ai-launchpad/…
  string odataPath = "/odata/v4/ai-launchpad";
  size_t maxPageSize = 500;
  size_t maxRequestBytes = 4 * 1024 * 1024;
  string authMode = "open"; /// open | jwt (built-in login); an XSUAA binding always wins
  string jwtSecret; /// HS256 secret of the built-in login (>= 32 characters; "" = random per start)
  long tokenTtlSeconds = 3600;
  string adminUser = "admin"; /// created on first start in jwt mode
  string adminPassword; /// "" = generated and logged once
  uint passwordIterations = 120_000; /// PBKDF2 rounds
  bool persistAuditLog = true; /// audit trail also into the audit log of the administration
  string frontendDir = "../frontend";
  uint reconcileIntervalSeconds = 15; /// reconcile worker; 0 = only on demand
  uint purgeEveryRuns = 240; /// audit log purge every n-th worker run
  string[] workerTenants = ["default"];
  string runtimeMode = "simulate"; /// simulate (deterministic AI runtime simulation)
  uint simulatedExecutionSeconds = 60; /// duration of a simulated training run
  uint simulatedDeploymentSeconds = 5; /// start-up time of a simulated deployment
  uint simulatedFailurePercent = 0; /// random failures of the simulation (chaos testing)
  AilpPolicy policy;
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
  AilpConfig d;
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
  j["logRetentionDays"] = d.policy.logRetentionDays;
  j["maxReconcileBatch"] = d.policy.maxReconcileBatch;
  j["persistAuditLog"] = d.persistAuditLog;
  j["frontendDir"] = d.frontendDir;
  j["reconcileIntervalSeconds"] = d.reconcileIntervalSeconds;
  j["purgeEveryRuns"] = d.purgeEveryRuns;
  auto tenants = Json.emptyArray;
  foreach (t; d.workerTenants)
    tenants ~= Json(t);
  j["workerTenants"] = tenants;
  j["runtimeMode"] = d.runtimeMode;
  j["simulatedExecutionSeconds"] = d.simulatedExecutionSeconds;
  j["simulatedDeploymentSeconds"] = d.simulatedDeploymentSeconds;
  j["simulatedFailurePercent"] = d.simulatedFailurePercent;
  return j;
}

/// Load the layered configuration.
AilpConfig loadAilpConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  AilpConfig c;
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
  c.policy.logRetentionDays = number(j, "logRetentionDays", c.policy.logRetentionDays);
  c.policy.maxReconcileBatch = cast(size_t) number(j, "maxReconcileBatch", c.policy.maxReconcileBatch);
  c.persistAuditLog = flag(j, "persistAuditLog", c.persistAuditLog);
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.reconcileIntervalSeconds = cast(uint) number(j, "reconcileIntervalSeconds", c.reconcileIntervalSeconds);
  c.purgeEveryRuns = cast(uint) number(j, "purgeEveryRuns", c.purgeEveryRuns);
  if ("workerTenants" in j && j["workerTenants"].type == Json.Type.array) {
    c.workerTenants = null;
    foreach (t; j["workerTenants"])
      if (t.type == Json.Type.string)
        c.workerTenants ~= t.get!string;
  } else if ("workerTenants" in j && j["workerTenants"].type == Json.Type.string) // env: "a,b"
    c.workerTenants = j["workerTenants"].get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  c.runtimeMode = text(j, "runtimeMode", c.runtimeMode).strip.toLower;
  c.simulatedExecutionSeconds = cast(uint) number(j, "simulatedExecutionSeconds", c.simulatedExecutionSeconds);
  c.simulatedDeploymentSeconds = cast(uint) number(j, "simulatedDeploymentSeconds", c.simulatedDeploymentSeconds);
  c.simulatedFailurePercent = cast(uint) number(j, "simulatedFailurePercent", c.simulatedFailurePercent);
  validateConfig(c);
  return c;
}

void validateConfig(const AilpConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.apiPath != c.odataPath, "apiPath and odataPath must differ");
  enforce(c.maxRequestBytes >= 4096, "maxRequestBytes must be at least 4096");
  enforce(c.reconcileIntervalSeconds <= 86_400, "reconcileIntervalSeconds must be between 0 and 86400");
  enforce(c.purgeEveryRuns >= 1, "purgeEveryRuns must be at least 1");
  enforce(["open", "jwt"].canFind(c.authMode), "authMode must be 'open' or 'jwt', not '" ~ c.authMode ~ "'");
  enforce(c.jwtSecret.length == 0 || c.jwtSecret.length >= 32, "jwtSecret must have at least 32 characters");
  enforce(c.tokenTtlSeconds >= 60 && c.tokenTtlSeconds <= 7 * 86_400, "tokenTtlSeconds must be between 60 and 604800");
  enforce(c.passwordIterations >= 1000, "passwordIterations must be at least 1000");
  enforce(isValidId(c.adminUser), "adminUser '" ~ c.adminUser ~ "' is not a valid user name");
  enforce(c.policy.minPasswordLength >= 8, "minPasswordLength must be at least 8");
  enforce(c.policy.logRetentionDays >= 1 && c.policy.logRetentionDays <= 3650, "logRetentionDays must be between 1 and 3650");
  enforce(c.policy.maxReconcileBatch >= 1 && c.policy.maxReconcileBatch <= 100_000,
    "maxReconcileBatch must be between 1 and 100000");
  enforce(["simulate"].canFind(c.runtimeMode), "runtimeMode must be 'simulate', not '" ~ c.runtimeMode ~ "'");
  enforce(c.simulatedExecutionSeconds <= 86_400, "simulatedExecutionSeconds must be between 0 and 86400");
  enforce(c.simulatedDeploymentSeconds <= 3600, "simulatedDeploymentSeconds must be between 0 and 3600");
  enforce(c.simulatedFailurePercent <= 100, "simulatedFailurePercent must be between 0 and 100");
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
  o["odataPath"] = "odata/v4/ailp/";
  o["reconcileIntervalSeconds"] = 0;
  auto c = loadAilpConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/ailp");
  assert(c.reconcileIntervalSeconds == 0 && c.authMode == "open" && c.persistAuditLog);
  o["requireAuthentication"] = true;
  assert(loadAilpConfig(o, "/nonexistent").authMode == "jwt");
  o.remove("requireAuthentication");
  assert(loadAilpConfig(o, "/nonexistent").toMaskedJson()["jwtSecret"].get!string == "");
  o["storage"] = "floppy";
  bool failed;
  try
    loadAilpConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
