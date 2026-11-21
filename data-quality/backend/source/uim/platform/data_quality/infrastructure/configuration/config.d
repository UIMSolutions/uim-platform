/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → DQ_<KEY> environment variables (e.g. DQ_PORT, DQ_STORAGE, DQ_DATA_FILE)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "data-quality-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.data_quality.infrastructure.configuration.config;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "DQ";

/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "data-quality-config";

struct DqConfig {
  string serviceName = "uim-data-quality";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8086;
  string storage = "memory"; /// memory | file
  string dataFile = "data/data-quality.json";
  string defaultTenant = "default";
  string apiPath = "/api/v1"; /// REST: <apiPath>/validate, /addresses/cleanse, /datasets/{id}/records, …
  string odataPath = "/odata/v4/data-quality";
  size_t maxPageSize = 200;
  size_t maxRequestBytes = 16 * 1024 * 1024;
  bool requireAuthentication;
  string jwtSecret; /// HS256 secret (non-BTP setups)
  string frontendDir = "../frontend";
  uint jobIntervalSeconds = 5; /// cleansing job worker; 0 = run jobs on creation
  string[] jobTenants = ["default"];
  DqPolicy policy;

  Json raw; /// the merged document (incl. "services" from VCAP_SERVICES)
  string[] sources; /// where values came from (for diagnostics)

  /// Effective configuration with secrets masked.
  Json toMaskedJson() @trusted {
    auto j = raw.clone;
    if ("jwtSecret" in j && j["jwtSecret"].type == Json.Type.string && j["jwtSecret"].get!string.length)
      j["jwtSecret"] = "***";
    if ("services" in j)
      j["services"] = "*** (" ~ j["services"].length.to!string ~ " bound services)";
    return j;
  }
}

/// Built-in defaults as JSON (also the set of keys env vars may override).
Json defaultConfigJson() {
  DqConfig d;
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
  j["requireAuthentication"] = d.requireAuthentication;
  j["jwtSecret"] = "";
  j["frontendDir"] = d.frontendDir;
  j["jobIntervalSeconds"] = d.jobIntervalSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.jobTenants)
    tenants ~= Json(t);
  j["jobTenants"] = tenants;
  j["autoValidate"] = d.policy.autoValidate;
  j["maxSnapshots"] = d.policy.maxSnapshots;
  j["maxImportRecords"] = d.policy.maxImportRecords;
  j["maxPairwiseRecords"] = d.policy.maxPairwiseRecords;
  return j;
}

/// Load the layered configuration.
DqConfig loadDqConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  DqConfig c;
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
  c.storage = text(j, "storage", c.storage);
  c.dataFile = text(j, "dataFile", c.dataFile);
  c.defaultTenant = text(j, "defaultTenant", c.defaultTenant);
  c.apiPath = "/" ~ text(j, "apiPath", c.apiPath).strip("/");
  c.odataPath = "/" ~ text(j, "odataPath", c.odataPath).strip("/");
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.maxRequestBytes = cast(size_t) number(j, "maxRequestBytes", c.maxRequestBytes);
  c.requireAuthentication = flag(j, "requireAuthentication", c.requireAuthentication);
  c.jwtSecret = text(j, "jwtSecret", "");
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.jobIntervalSeconds = cast(uint) number(j, "jobIntervalSeconds", c.jobIntervalSeconds);
  if ("jobTenants" in j && j["jobTenants"].type == Json.Type.array) {
    c.jobTenants = null;
    foreach (t; j["jobTenants"])
      if (t.type == Json.Type.string)
        c.jobTenants ~= t.get!string;
  } else if ("jobTenants" in j && j["jobTenants"].type == Json.Type.string) // env: "a,b"
    c.jobTenants = j["jobTenants"].get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;

  c.policy.autoValidate = flag(j, "autoValidate", c.policy.autoValidate);
  c.policy.maxSnapshots = cast(size_t) number(j, "maxSnapshots", c.policy.maxSnapshots);
  c.policy.maxImportRecords = cast(size_t) number(j, "maxImportRecords", c.policy.maxImportRecords);
  c.policy.maxPairwiseRecords = cast(size_t) number(j, "maxPairwiseRecords", c.policy.maxPairwiseRecords);
  c.policy.runJobsImmediately = c.jobIntervalSeconds == 0;
  validateConfig(c);
  return c;
}

void validateConfig(const DqConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.apiPath != c.odataPath, "apiPath and odataPath must differ");
  enforce(c.maxRequestBytes >= 1024, "maxRequestBytes must be at least 1024");
  enforce(c.policy.maxImportRecords > 0, "maxImportRecords must be > 0");
  enforce(c.jobIntervalSeconds <= 86_400, "jobIntervalSeconds must be between 0 and 86400");
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
  o["odataPath"] = "odata/v4/dq/";
  o["jobIntervalSeconds"] = 0;
  auto c = loadDqConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/dq");
  assert(c.policy.runJobsImmediately && c.policy.autoValidate);

  o["storage"] = "tape";
  bool failed;
  try
    loadDqConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
