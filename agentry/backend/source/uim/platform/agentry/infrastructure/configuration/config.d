/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (AGENTRY_CONFIG_FILE or config/default.json)
///   3. environment variables (AGENTRY_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "agentry-config"
struct AgentryConfig {
  string serviceName = "Agentry Service";
  string host = "0.0.0.0";
  ushort port = 8117;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string apiPath = "/api/v1/agentry";
  string restPath = "/rest/v1/agentry";
  string odataPath = "/odata/v4/agentry";
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";
  /// Timeout of a backend connectivity test (0 = probing disabled).
  int probeTimeoutSeconds = 5;
  /// Sync watchdog: check every N minutes (0 = off) and fail sessions
  /// running longer than syncTimeoutMinutes.
  int watchdogIntervalMinutes = 0;
  int syncTimeoutMinutes = 60;
  string[] watchdogTenants = ["default"];

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// Apply a flat JSON object of settings.
  void apply(Json values, string source) {
    if (values.type != Json.Type.object)
      return;

    int asInt(Json v) {
      return v.type == Json.Type.string ? v.get!string.to!int : cast(int) v.get!long;
    }

    if (auto v = "serviceName" in values) serviceName = v.get!string;
    if (auto v = "host" in values) host = v.get!string;
    if (auto v = "port" in values) port = cast(ushort) asInt(*v);
    if (auto v = "logLevel" in values) logLevel = v.get!string;
    if (auto v = "storage" in values) storage = v.get!string;
    if (auto v = "dataDir" in values) dataDir = v.get!string;
    if (auto v = "defaultTenant" in values) defaultTenant = v.get!string;
    if (auto v = "apiPath" in values) apiPath = v.get!string;
    if (auto v = "restPath" in values) restPath = v.get!string;
    if (auto v = "odataPath" in values) odataPath = v.get!string;
    if (auto v = "frontendDir" in values) frontendDir = v.get!string;
    if (auto v = "probeTimeoutSeconds" in values) probeTimeoutSeconds = asInt(*v);
    if (auto v = "watchdogIntervalMinutes" in values) watchdogIntervalMinutes = asInt(*v);
    if (auto v = "syncTimeoutMinutes" in values) syncTimeoutMinutes = asInt(*v);
    if (auto v = "watchdogTenants" in values) {
      if (v.type == Json.Type.array) {
        watchdogTenants = null;
        foreach (t; v.get!(Json[]))
          watchdogTenants ~= t.get!string;
      } else if (v.type == Json.Type.string) {
        watchdogTenants = v.get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
      }
    }
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    auto tenants = Json.emptyArray;
    foreach (t; watchdogTenants)
      tenants ~= Json(t);
    auto origins = Json.emptyArray;
    foreach (s; sources)
      origins ~= Json(s);
    return Json.emptyObject
      .set("serviceName", serviceName)
      .set("host", host)
      .set("port", port)
      .set("logLevel", logLevel)
      .set("storage", storage)
      .set("dataDir", dataDir)
      .set("defaultTenant", defaultTenant)
      .set("apiPath", apiPath)
      .set("restPath", restPath)
      .set("odataPath", odataPath)
      .set("frontendDir", frontendDir)
      .set("probeTimeoutSeconds", probeTimeoutSeconds)
      .set("watchdogIntervalMinutes", watchdogIntervalMinutes)
      .set("syncTimeoutMinutes", syncTimeoutMinutes)
      .set("watchdogTenants", tenants)
      .set("sources", origins);
  }
}

/// Backwards compatible name.
alias SrvConfig = AgentryConfig;

/// Load configuration with the documented precedence.
AgentryConfig loadConfig() {
  AgentryConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("agentry: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }

  fromEnv("AGENTRY_SERVICE_NAME", "serviceName");
  fromEnv("AGENTRY_HOST", "host");
  fromEnv("AGENTRY_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("AGENTRY_LOG_LEVEL", "logLevel");
  fromEnv("AGENTRY_STORAGE", "storage");
  fromEnv("AGENTRY_DATA_DIR", "dataDir");
  fromEnv("AGENTRY_DEFAULT_TENANT", "defaultTenant");
  fromEnv("AGENTRY_ODATA_PATH", "odataPath");
  fromEnv("AGENTRY_FRONTEND_DIR", "frontendDir");
  fromEnv("AGENTRY_PROBE_TIMEOUT", "probeTimeoutSeconds");
  fromEnv("AGENTRY_WATCHDOG_INTERVAL", "watchdogIntervalMinutes");
  fromEnv("AGENTRY_SYNC_TIMEOUT", "syncTimeoutMinutes");
  fromEnv("AGENTRY_WATCHDOG_TENANTS", "watchdogTenants");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("agentry: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "agentry-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("agentry: cannot parse VCAP_SERVICES: %s", e.msg);
    }
  }

  return config;
}

/// Find the credentials of a bound service by instance name, binding name or tag.
Json findServiceCredentials(Json vcapServices, string nameOrTag) {
  if (vcapServices.type != Json.Type.object)
    return Json.undefined;
  foreach (label, instances; vcapServices.get!(Json[string])) {
    if (instances.type != Json.Type.array)
      continue;
    foreach (instance; instances.get!(Json[])) {
      bool match = instance.fieldString("name") == nameOrTag
        || instance.fieldString("binding_name") == nameOrTag
        || instance.fieldStrings("tags").canFind(nameOrTag);
      if (match && "credentials" in instance)
        return instance["credentials"];
    }
  }
  return Json.undefined;
}

private string locateConfigFile() {
  auto explicit = environment.get("AGENTRY_CONFIG_FILE", "");
  if (explicit.length > 0)
    return explicit.exists ? explicit : "";

  string[] candidates = [buildPath("config", "default.json"), buildPath("backend", "config", "default.json")];
  try {
    auto exeDir = (() @trusted => thisExePath.dirName)();
    candidates ~= buildPath(exeDir, "..", "config", "default.json");
    candidates ~= buildPath(exeDir, "config", "default.json");
  } catch (Exception) {
  }
  foreach (c; candidates)
    if (c.exists)
      return c;
  return "";
}
///
unittest {
  mixin(ShowTest!("AgentryConfig"));

  AgentryConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "watchdogTenants": "a, b"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.watchdogTenants == ["a", "b"]);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "agentry-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "agentry-config"), "vcap");
  assert(cfg.port == 9100);
  assert(cfg.sources == ["defaults", "test", "vcap"]);
}
