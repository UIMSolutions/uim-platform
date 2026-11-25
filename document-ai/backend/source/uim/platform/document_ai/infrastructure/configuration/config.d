/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → DOCAI_<KEY> environment variables (e.g. DOCAI_PORT, DOCAI_STORAGE, DOCAI_JWT_SECRET)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "document-ai-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.document_ai.infrastructure.configuration.config;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "DOCAI";
/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "document-ai-config";

struct DaiConfig {
  string serviceName = "uim-document-ai";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8096;
  string storage = "memory"; /// memory | file
  string dataFile = "data/document-ai.json";
  string defaultTenant = "default";
  string apiPath = "/api/v1"; /// REST: <apiPath>/document-ai/…
  string odataPath = "/odata/v4/document-ai";
  size_t maxPageSize = 200;
  size_t maxRequestBytes = 4 * 1024 * 1024;
  string authMode = "open"; /// open | jwt (built-in login); an XSUAA binding always wins
  string jwtSecret; /// HS256 secret of the built-in login (>= 32 characters; "" = random per start)
  long tokenTtlSeconds = 3600;
  string adminUser = "admin"; /// created on first start in jwt mode
  string adminPassword; /// "" = generated and logged once
  uint passwordIterations = 120_000; /// PBKDF2 rounds
  string frontendDir = "../frontend";
  uint workerIntervalSeconds = 5; /// pending documents / training jobs; 0 = extract on upload
  string[] workerTenants = ["default"];
  string extractionMode = "simulate"; /// simulate | http
  string extractionUrl; /// http mode: the extraction endpoint
  uint extractionTimeoutSeconds = 60;
  DaiPolicy policy;
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
  DaiConfig d;
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
  j["minConfidence"] = d.policy.minConfidence;
  j["minTrainingDocuments"] = d.policy.minTrainingDocuments;
  j["trainingSeconds"] = d.policy.trainingSeconds;
  j["maxDocumentsPerRun"] = d.policy.maxDocumentsPerRun;
  j["frontendDir"] = d.frontendDir;
  j["workerIntervalSeconds"] = d.workerIntervalSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.workerTenants)
    tenants ~= Json(t);
  j["workerTenants"] = tenants;
  j["extractionMode"] = d.extractionMode;
  j["extractionUrl"] = "";
  j["extractionTimeoutSeconds"] = d.extractionTimeoutSeconds;
  return j;
}

/// Load the layered configuration.
DaiConfig loadDaiConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  DaiConfig c;
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
  c.policy.minConfidence = real_(j, "minConfidence", c.policy.minConfidence);
  c.policy.minTrainingDocuments = cast(int) number(j, "minTrainingDocuments", c.policy.minTrainingDocuments);
  c.policy.trainingSeconds = number(j, "trainingSeconds", c.policy.trainingSeconds);
  c.policy.maxDocumentsPerRun = cast(size_t) number(j, "maxDocumentsPerRun", c.policy.maxDocumentsPerRun);
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.workerIntervalSeconds = cast(uint) number(j, "workerIntervalSeconds", c.workerIntervalSeconds);
  if ("workerTenants" in j && j["workerTenants"].type == Json.Type.array) {
    c.workerTenants = null;
    foreach (t; j["workerTenants"])
      if (t.type == Json.Type.string)
        c.workerTenants ~= t.get!string;
  } else if ("workerTenants" in j && j["workerTenants"].type == Json.Type.string) // env: "a,b"
    c.workerTenants = j["workerTenants"].get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  c.extractionMode = text(j, "extractionMode", c.extractionMode).strip.toLower;
  c.extractionUrl = text(j, "extractionUrl", "").strip;
  c.extractionTimeoutSeconds = cast(uint) number(j, "extractionTimeoutSeconds", c.extractionTimeoutSeconds);
  c.policy.processImmediately = c.workerIntervalSeconds == 0;
  validateConfig(c);
  return c;
}

void validateConfig(const DaiConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.apiPath != c.odataPath, "apiPath and odataPath must differ");
  enforce(c.maxRequestBytes >= 1024, "maxRequestBytes must be at least 1024");
  enforce(c.workerIntervalSeconds <= 86_400, "workerIntervalSeconds must be between 0 and 86400");
  enforce(["open", "jwt"].canFind(c.authMode), "authMode must be 'open' or 'jwt', not '" ~ c.authMode ~ "'");
  enforce(c.jwtSecret.length == 0 || c.jwtSecret.length >= 32, "jwtSecret must have at least 32 characters");
  enforce(c.tokenTtlSeconds >= 60 && c.tokenTtlSeconds <= 7 * 86_400, "tokenTtlSeconds must be between 60 and 604800");
  enforce(c.passwordIterations >= 1000, "passwordIterations must be at least 1000");
  enforce(isValidId(c.adminUser), "adminUser '" ~ c.adminUser ~ "' is not a valid user name");
  enforce(c.policy.minPasswordLength >= 8, "minPasswordLength must be at least 8");
  enforce(c.policy.minConfidence >= 0 && c.policy.minConfidence <= 1, "minConfidence must be between 0 and 1");
  enforce(c.policy.minTrainingDocuments >= 1 && c.policy.minTrainingDocuments <= 100_000,
    "minTrainingDocuments must be between 1 and 100000");
  enforce(c.policy.trainingSeconds >= 0 && c.policy.trainingSeconds <= 86_400, "trainingSeconds must be between 0 and 86400");
  enforce(c.policy.maxDocumentsPerRun >= 1, "maxDocumentsPerRun must be at least 1");
  enforce(["simulate", "http"].canFind(c.extractionMode), "extractionMode must be 'simulate' or 'http', not '"
      ~ c.extractionMode ~ "'");
  enforce(c.extractionMode != "http" || c.extractionUrl.startsWith("http://") || c.extractionUrl.startsWith("https://"),
    "extractionMode 'http' needs an extractionUrl (http:// or https://)");
  enforce(c.extractionTimeoutSeconds >= 1 && c.extractionTimeoutSeconds <= 900, "extractionTimeoutSeconds must be between 1 and 900");
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

private double real_(Json j, string key, double fallback) @trusted {
  if (key !in j)
    return fallback;
  if (j[key].type == Json.Type.float_)
    return j[key].get!double;
  if (j[key].type == Json.Type.int_)
    return cast(double) j[key].get!long;
  if (j[key].type == Json.Type.string) {
    try
      return j[key].get!string.strip.to!double;
    catch (Exception) {
    }
  }
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
  o["odataPath"] = "odata/v4/dai/";
  o["workerIntervalSeconds"] = 0;
  o["minConfidence"] = "0.8";
  auto c = loadDaiConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/dai");
  assert(c.policy.processImmediately && c.authMode == "open" && c.policy.minConfidence == 0.8);
  o["requireAuthentication"] = true;
  assert(loadDaiConfig(o, "/nonexistent").authMode == "jwt");
  o.remove("requireAuthentication");
  assert(loadDaiConfig(o, "/nonexistent").toMaskedJson()["jwtSecret"].get!string == "");
  o["extractionMode"] = "http";
  bool failed;
  try
    loadDaiConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
