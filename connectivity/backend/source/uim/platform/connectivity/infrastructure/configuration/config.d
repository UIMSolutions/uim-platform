/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (CONN_CONFIG_FILE or config/default.json)
///   3. environment variables (CONN_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "connectivity-config"
struct ConnectivityConfig {
  string serviceName = "Connectivity Service";
  string host = "0.0.0.0";
  ushort port = 8088;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/connectivity";
  /// Run the health check every N seconds in the server (0 = off).
  int healthCheckIntervalSeconds = 30;
  string[] healthCheckTenants = ["default"];
  int heartbeatTimeoutSeconds = 300;
  int certificateWarningDays = 30;
  int maxLogEntries = 5000;
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// The monitoring thresholds as a domain value.
  MonitoringPolicy policy() const {
    MonitoringPolicy p;
    p.heartbeatTimeoutSeconds = heartbeatTimeoutSeconds;
    p.certificateWarningDays = certificateWarningDays;
    p.maxLogEntries = maxLogEntries;
    return p;
  }

  /// Apply a flat JSON object of settings (strings are coerced).
  void apply(Json values, string source) {
    if (values.type != Json.Type.object)
      return;
    if (auto v = "serviceName" in values) serviceName = jsonText(*v);
    if (auto v = "host" in values) host = jsonText(*v);
    if (auto v = "port" in values) port = cast(ushort) jsonLong(*v, port);
    if (auto v = "logLevel" in values) logLevel = jsonText(*v);
    if (auto v = "storage" in values) storage = jsonText(*v);
    if (auto v = "dataDir" in values) dataDir = jsonText(*v);
    if (auto v = "defaultTenant" in values) defaultTenant = jsonText(*v);
    if (auto v = "odataPath" in values) odataPath = jsonText(*v);
    if (auto v = "frontendDir" in values) frontendDir = jsonText(*v);
    if (auto v = "healthCheckIntervalSeconds" in values)
      healthCheckIntervalSeconds = cast(int) jsonLong(*v, healthCheckIntervalSeconds);
    if (auto v = "healthCheckTenants" in values)
      healthCheckTenants = jsonStrings(*v);
    if (auto v = "heartbeatTimeoutSeconds" in values)
      heartbeatTimeoutSeconds = cast(int) jsonLong(*v, heartbeatTimeoutSeconds);
    if (auto v = "certificateWarningDays" in values)
      certificateWarningDays = cast(int) jsonLong(*v, certificateWarningDays);
    if (auto v = "maxLogEntries" in values)
      maxLogEntries = cast(int) jsonLong(*v, maxLogEntries);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    auto tenants = Json.emptyArray;
    foreach (t; healthCheckTenants)
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
      .set("odataPath", odataPath)
      .set("healthCheckIntervalSeconds", healthCheckIntervalSeconds)
      .set("healthCheckTenants", tenants)
      .set("heartbeatTimeoutSeconds", heartbeatTimeoutSeconds)
      .set("certificateWarningDays", certificateWarningDays)
      .set("maxLogEntries", maxLogEntries)
      .set("frontendDir", frontendDir)
      .set("sources", origins);
  }
}

/// Load configuration with the documented precedence.
ConnectivityConfig loadConfig() {
  ConnectivityConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("connectivity: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("CONN_SERVICE_NAME", "serviceName");
  fromEnv("CONN_HOST", "host");
  fromEnv("CONN_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("CONN_LOG_LEVEL", "logLevel");
  fromEnv("CONN_STORAGE", "storage");
  fromEnv("CONN_DATA_DIR", "dataDir");
  fromEnv("CONN_DEFAULT_TENANT", "defaultTenant");
  fromEnv("CONN_ODATA_PATH", "odataPath");
  fromEnv("CONN_HEALTH_CHECK_INTERVAL", "healthCheckIntervalSeconds");
  fromEnv("CONN_HEALTH_CHECK_TENANTS", "healthCheckTenants");
  fromEnv("CONN_HEARTBEAT_TIMEOUT", "heartbeatTimeoutSeconds");
  fromEnv("CONN_CERTIFICATE_WARNING_DAYS", "certificateWarningDays");
  fromEnv("CONN_MAX_LOG_ENTRIES", "maxLogEntries");
  fromEnv("CONN_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("connectivity: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "connectivity-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("connectivity: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("CONN_CONFIG_FILE", "");
  if (explicit.length > 0)
    return explicit.exists ? explicit : "";

  string[] candidates = [buildPath("config", "default.json"), buildPath("backend", "config", "default.json")];
  try {
    auto exeDir = (() @trusted => thisExePath.dirName)();
    candidates ~= buildPath(exeDir, "..", "config", "default.json");
  } catch (Exception) {
  }
  foreach (c; candidates)
    if (c.exists)
      return c;
  return "";
}

///
unittest {
  mixin(ShowTest!("ConnectivityConfig"));

  ConnectivityConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "healthCheckTenants": "a, b", "heartbeatTimeoutSeconds": "60"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.healthCheckTenants == ["a", "b"]);
  assert(cfg.policy.heartbeatTimeoutSeconds == 60);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "connectivity-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "connectivity-config"), "vcap");
  assert(cfg.port == 9100);
}
