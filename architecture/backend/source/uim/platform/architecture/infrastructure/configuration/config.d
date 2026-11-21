/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → ARCHITECTURE_<KEY> environment variables (e.g. ARCHITECTURE_PORT, ARCHITECTURE_STORAGE)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "architecture-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.architecture.infrastructure.configuration.config;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "ARCHITECTURE";

/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "architecture-config";

struct ArchitectureConfig {
  string serviceName = "uim-architecture";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8122;
  string storage = "memory"; /// memory | file
  string dataFile = "data/architecture.json";
  string defaultTenant = "default";
  string apiPath = "/api/v1"; /// REST: <apiPath>/building-blocks, /relationships, /analysis, /export
  string odataPath = "/odata/v4/architecture";
  size_t maxPageSize = 200;
  bool requireAuthentication;
  string jwtSecret; /// HS256 secret (non-BTP setups)
  string frontendDir = "../frontend";
  bool seedDemoData; /// create the demo landscape in the default tenant if it is empty

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
  ArchitectureConfig d;
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
  j["requireAuthentication"] = d.requireAuthentication;
  j["jwtSecret"] = "";
  j["frontendDir"] = d.frontendDir;
  j["seedDemoData"] = d.seedDemoData;
  return j;
}

/// Load the layered configuration.
ArchitectureConfig loadArchitectureConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  ArchitectureConfig c;
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
  c.requireAuthentication = flag(j, "requireAuthentication", c.requireAuthentication);
  c.jwtSecret = text(j, "jwtSecret", "");
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.seedDemoData = flag(j, "seedDemoData", c.seedDemoData);
  validateConfig(c);
  return c;
}

void validateConfig(const ArchitectureConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.apiPath != c.odataPath, "apiPath and odataPath must differ");
  enforce(c.apiPath.length > 1 && c.odataPath.length > 1, "apiPath and odataPath must not be '/'");
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
  o["port"] = 9122;
  o["odataPath"] = "odata/v4/ea/";
  auto c = loadArchitectureConfig(o, "/nonexistent");
  assert(c.port == 9122 && c.storage == "memory" && c.odataPath == "/odata/v4/ea" && c.apiPath == "/api/v1");

  o["storage"] = "tape";
  bool failed;
  try
    loadArchitectureConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
