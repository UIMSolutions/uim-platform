/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → AICORE_<KEY> environment variables (e.g. AICORE_PORT, AICORE_STORAGE)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "ai-core-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.ai_core.infrastructure.configuration.config;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "AICORE";

/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "ai-core-config";

struct AiCoreConfig {
  string serviceName = "uim-ai-core";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8090;
  string storage = "memory"; /// memory | file
  string dataFile = "data/ai-core.json";
  string defaultTenant = "default";
  string defaultResourceGroup = "default"; /// created on first use; "" = off
  string aiApiPath = "/api/v2"; /// AI API v2: <aiApiPath>/lm/..., <aiApiPath>/admin/...
  string odataPath = "/odata/v4/ai-core";
  size_t maxPageSize = 200;
  bool requireAuthentication;
  string jwtSecret; /// HS256 secret (non-BTP setups)
  string frontendDir = "../frontend";
  string publicUrl; /// external base URL (default: VCAP application URI or http://localhost:<port>)
  uint reconcileIntervalSeconds = 5; /// 0 = no background reconciler
  string[] reconcileTenants = ["default"];
  LifecyclePolicy lifecycle;

  Json raw; /// the merged document (incl. "services" from VCAP_SERVICES)
  string[] sources; /// where values came from (for diagnostics)

  /// Effective configuration with secrets masked.
  Json toMaskedJson() @trusted {
    auto j = raw.clone;
    if ("jwtSecret" in j && j["jwtSecret"].type == Json.Type.string && j["jwtSecret"].get!string.length)
      j["jwtSecret"] = "***";
    if ("services" in j)
      j["services"] = "*** (" ~ j["services"].length.to!string ~ " bound services)";
    j["publicUrl"] = publicUrl;
    j["inferenceBaseUrl"] = lifecycle.inferenceBaseUrl;
    return j;
  }
}

/// Built-in defaults as JSON (also the set of keys env vars may override).
Json defaultConfigJson() {
  AiCoreConfig d;
  auto j = Json.emptyObject;
  j["serviceName"] = d.serviceName;
  j["serviceVersion"] = d.serviceVersion;
  j["host"] = d.host;
  j["port"] = d.port;
  j["storage"] = d.storage;
  j["dataFile"] = d.dataFile;
  j["defaultTenant"] = d.defaultTenant;
  j["defaultResourceGroup"] = d.defaultResourceGroup;
  j["aiApiPath"] = d.aiApiPath;
  j["odataPath"] = d.odataPath;
  j["maxPageSize"] = d.maxPageSize;
  j["requireAuthentication"] = d.requireAuthentication;
  j["jwtSecret"] = "";
  j["frontendDir"] = d.frontendDir;
  j["publicUrl"] = "";
  j["reconcileIntervalSeconds"] = d.reconcileIntervalSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.reconcileTenants)
    tenants ~= Json(t);
  j["reconcileTenants"] = tenants;
  j["provisionSeconds"] = d.lifecycle.provisionSeconds;
  j["executionStartSeconds"] = d.lifecycle.executionStartSeconds;
  j["executionRunSeconds"] = d.lifecycle.executionRunSeconds;
  j["deploymentStartSeconds"] = d.lifecycle.deploymentStartSeconds;
  j["inferenceBaseUrl"] = "";
  return j;
}

/// Load the layered configuration.
AiCoreConfig loadAiCoreConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  AiCoreConfig c;
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
  c.defaultResourceGroup = text(j, "defaultResourceGroup", c.defaultResourceGroup);
  c.aiApiPath = "/" ~ text(j, "aiApiPath", c.aiApiPath).strip("/");
  c.odataPath = "/" ~ text(j, "odataPath", c.odataPath).strip("/");
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.requireAuthentication = flag(j, "requireAuthentication", c.requireAuthentication);
  c.jwtSecret = text(j, "jwtSecret", "");
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.reconcileIntervalSeconds = cast(uint) number(j, "reconcileIntervalSeconds", c.reconcileIntervalSeconds);
  if ("reconcileTenants" in j && j["reconcileTenants"].type == Json.Type.array) {
    c.reconcileTenants = null;
    foreach (t; j["reconcileTenants"])
      if (t.type == Json.Type.string)
        c.reconcileTenants ~= t.get!string;
  } else if ("reconcileTenants" in j && j["reconcileTenants"].type == Json.Type.string) // env: "a,b"
    c.reconcileTenants = j["reconcileTenants"].get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;

  c.lifecycle.provisionSeconds = number(j, "provisionSeconds", c.lifecycle.provisionSeconds);
  c.lifecycle.executionStartSeconds = number(j, "executionStartSeconds", c.lifecycle.executionStartSeconds);
  c.lifecycle.executionRunSeconds = number(j, "executionRunSeconds", c.lifecycle.executionRunSeconds);
  c.lifecycle.deploymentStartSeconds = number(j, "deploymentStartSeconds", c.lifecycle.deploymentStartSeconds);

  c.publicUrl = text(j, "publicUrl", "").stripRight("/");
  if (c.publicUrl.length == 0)
    c.publicUrl = "http://localhost:" ~ c.port.to!string;
  auto inference = text(j, "inferenceBaseUrl", "").stripRight("/");
  c.lifecycle.inferenceBaseUrl = inference.length > 0 ? inference : c.publicUrl ~ c.aiApiPath ~ "/inference";
  validateConfig(c);
  return c;
}

void validateConfig(const AiCoreConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.defaultResourceGroup.length == 0 || isValidResourceGroupId(c.defaultResourceGroup),
    "defaultResourceGroup '" ~ c.defaultResourceGroup ~ "' is not a valid resource group id");
  enforce(c.aiApiPath != c.odataPath, "aiApiPath and odataPath must differ");
  foreach (name, v; ["provisionSeconds": c.lifecycle.provisionSeconds,
      "executionStartSeconds": c.lifecycle.executionStartSeconds, "executionRunSeconds": c.lifecycle.executionRunSeconds,
      "deploymentStartSeconds": c.lifecycle.deploymentStartSeconds])
    enforce(v >= 0 && v <= 86_400, name ~ " must be between 0 and 86400");
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
  o["odataPath"] = "odata/v4/ai/";
  o["executionRunSeconds"] = 3;
  auto c = loadAiCoreConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/ai");
  assert(c.lifecycle.executionRunSeconds == 3);
  assert(c.lifecycle.inferenceBaseUrl == "http://localhost:9001/api/v2/inference");

  o["storage"] = "tape";
  bool failed;
  try
    loadAiCoreConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
