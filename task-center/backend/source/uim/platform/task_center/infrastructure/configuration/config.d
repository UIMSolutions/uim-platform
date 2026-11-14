/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → TASK_CENTER_<KEY> environment variables (e.g. TASK_CENTER_PORT,
///     TASK_CENTER_DATA_FILE) → Cloud Foundry (PORT, VCAP_SERVICES)
///   → explicit overrides (CLI/GUI options)
module uim.platform.task_center.infrastructure.configuration.config;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "TASK_CENTER";

struct TaskCenterConfig {
  string serviceName = "uim-task-center";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8103;
  string storage = "memory"; /// memory | file
  string dataFile = "data/task-center.json";
  string defaultTenant = "default";
  string restPath = "/api/v1/task-center";
  string odataPath = "/odata/v4/task-center";
  size_t maxPageSize = 200;
  bool requireAuthentication;
  string jwtSecret;
  string frontendDir = "../frontend";
  uint syncIntervalSeconds; /// 0 = providers are synced on demand only
  uint providerTimeoutSeconds = 15;
  string[] syncTenants = ["default"];

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
  TaskCenterConfig d;
  auto j = Json.emptyObject;
  j["serviceName"] = d.serviceName;
  j["serviceVersion"] = d.serviceVersion;
  j["host"] = d.host;
  j["port"] = d.port;
  j["storage"] = d.storage;
  j["dataFile"] = d.dataFile;
  j["defaultTenant"] = d.defaultTenant;
  j["restPath"] = d.restPath;
  j["odataPath"] = d.odataPath;
  j["maxPageSize"] = d.maxPageSize;
  j["requireAuthentication"] = d.requireAuthentication;
  j["jwtSecret"] = d.jwtSecret;
  j["frontendDir"] = d.frontendDir;
  j["syncIntervalSeconds"] = d.syncIntervalSeconds;
  j["providerTimeoutSeconds"] = d.providerTimeoutSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.syncTenants)
    tenants ~= Json(t);
  j["syncTenants"] = tenants;
  return j;
}

/// Load the layered configuration.
TaskCenterConfig loadTaskCenterConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  foreach (k, v; overrides)
    j[k] = v;

  TaskCenterConfig c;
  c.raw = j;
  c.sources = ["defaults"];
  if (exists(buildPath(configDir, "default.json")))
    c.sources ~= buildPath(configDir, "default.json");
  c.sources ~= configEnvPrefix ~ "_* env";
  if (overrides.length)
    c.sources ~= "command line";

  c.serviceName = text(j, "serviceName", c.serviceName);
  c.serviceVersion = text(j, "serviceVersion", c.serviceVersion);
  c.host = text(j, "host", c.host);
  c.port = cast(ushort) number(j, "port", c.port);
  c.storage = text(j, "storage", c.storage);
  c.dataFile = text(j, "dataFile", c.dataFile);
  c.defaultTenant = text(j, "defaultTenant", c.defaultTenant);
  c.restPath = "/" ~ text(j, "restPath", c.restPath).strip("/");
  c.odataPath = "/" ~ text(j, "odataPath", c.odataPath).strip("/");
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.requireAuthentication = flag(j, "requireAuthentication", c.requireAuthentication);
  c.jwtSecret = text(j, "jwtSecret", c.jwtSecret);
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.syncIntervalSeconds = cast(uint) number(j, "syncIntervalSeconds", c.syncIntervalSeconds);
  c.providerTimeoutSeconds = cast(uint) number(j, "providerTimeoutSeconds", c.providerTimeoutSeconds);
  if ("syncTenants" in j && j["syncTenants"].type == Json.Type.array) {
    c.syncTenants = null;
    foreach (t; j["syncTenants"])
      if (t.type == Json.Type.string)
        c.syncTenants ~= t.get!string;
  } else if ("syncTenants" in j && j["syncTenants"].type == Json.Type.string) // env var: "a,b"
    c.syncTenants = j["syncTenants"].get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  validateConfig(c);
  return c;
}

void validateConfig(const TaskCenterConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.restPath != c.odataPath, "restPath and odataPath must differ");
  enforce(c.providerTimeoutSeconds > 0, "providerTimeoutSeconds must be > 0");
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
  o["odataPath"] = "odata/v4/tc/";
  auto c = loadTaskCenterConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/tc");
  assert(c.toMaskedJson()["port"].get!long == 9001);
}
