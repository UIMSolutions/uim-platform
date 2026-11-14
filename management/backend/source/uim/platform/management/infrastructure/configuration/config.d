/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (MGMT_CONFIG_FILE or config/default.json)
///   3. environment variables (MGMT_*, legacy MANAGEMENT_HOST / MANAGEMENT_PORT, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "management-config"
struct ManagementConfig {
  string serviceName = "Cloud Management Service";
  string host = "0.0.0.0";
  ushort port = 8098;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/management";
  /// Base path of the classic JSON API (HTTP controllers).
  string apiPath = "/api/v1";
  /// Base path of the vibe.d REST interfaces.
  string restPath = "/rest/v1/";
  /// Seed the default tenant with a demo landscape when it is empty.
  bool seedDemoData = false;
  /// Remove platform events older than this (0 = keep forever) …
  int eventRetentionDays = 0;
  /// … checked every N minutes (0 = worker off).
  int eventPruneIntervalMinutes = 0;
  /// Tenants handled by background workers.
  string[] workerTenants = ["default"];
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// Apply a flat JSON object of settings (numbers and booleans may be strings).
  void apply(Json values, string source) {
    if (values.type != Json.Type.object)
      return;
    if (auto v = "serviceName" in values) serviceName = v.get!string;
    if (auto v = "host" in values) host = v.get!string;
    if ("port" in values) port = cast(ushort) fieldInt(values, "port", port);
    if (auto v = "logLevel" in values) logLevel = v.get!string;
    if (auto v = "storage" in values) storage = v.get!string;
    if (auto v = "dataDir" in values) dataDir = v.get!string;
    if (auto v = "defaultTenant" in values) defaultTenant = v.get!string;
    if (auto v = "odataPath" in values) odataPath = v.get!string;
    if (auto v = "apiPath" in values) apiPath = v.get!string;
    if (auto v = "restPath" in values) restPath = v.get!string;
    if (auto v = "frontendDir" in values) frontendDir = v.get!string;
    if ("seedDemoData" in values) seedDemoData = fieldBool(values, "seedDemoData", seedDemoData);
    if ("eventRetentionDays" in values) eventRetentionDays = fieldInt(values, "eventRetentionDays", eventRetentionDays);
    if ("eventPruneIntervalMinutes" in values)
      eventPruneIntervalMinutes = fieldInt(values, "eventPruneIntervalMinutes", eventPruneIntervalMinutes);
    if ("workerTenants" in values)
      workerTenants = fieldStrings(values, "workerTenants");
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    return Json.emptyObject
      .set("serviceName", serviceName)
      .set("host", host)
      .set("port", port)
      .set("logLevel", logLevel)
      .set("storage", storage)
      .set("dataDir", dataDir)
      .set("defaultTenant", defaultTenant)
      .set("odataPath", odataPath)
      .set("apiPath", apiPath)
      .set("restPath", restPath)
      .set("seedDemoData", seedDemoData)
      .set("eventRetentionDays", eventRetentionDays)
      .set("eventPruneIntervalMinutes", eventPruneIntervalMinutes)
      .set("workerTenants", listToJson(workerTenants))
      .set("frontendDir", frontendDir)
      .set("sources", listToJson(sources));
  }
}

/// Backwards compatible name.
alias SrvConfig = ManagementConfig;

/// Load configuration with the documented precedence.
ManagementConfig loadConfig() {
  ManagementConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("management: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("MANAGEMENT_HOST", "host"); // legacy names
  fromEnv("MANAGEMENT_PORT", "port");
  fromEnv("MGMT_SERVICE_NAME", "serviceName");
  fromEnv("MGMT_HOST", "host");
  fromEnv("MGMT_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("MGMT_LOG_LEVEL", "logLevel");
  fromEnv("MGMT_STORAGE", "storage");
  fromEnv("MGMT_DATA_DIR", "dataDir");
  fromEnv("MGMT_DEFAULT_TENANT", "defaultTenant");
  fromEnv("MGMT_ODATA_PATH", "odataPath");
  fromEnv("MGMT_SEED_DEMO_DATA", "seedDemoData");
  fromEnv("MGMT_EVENT_RETENTION_DAYS", "eventRetentionDays");
  fromEnv("MGMT_EVENT_PRUNE_INTERVAL", "eventPruneIntervalMinutes");
  fromEnv("MGMT_WORKER_TENANTS", "workerTenants");
  fromEnv("MGMT_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("management: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "management-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("management: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("MGMT_CONFIG_FILE", "");
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
  mixin(ShowTest!("ManagementConfig"));

  ManagementConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "workerTenants": "a, b", "seedDemoData": "true"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.workerTenants == ["a", "b"]);
  assert(cfg.seedDemoData);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "management-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "management-config"), "vcap");
  assert(cfg.port == 9100);
  assert(cfg.sources == ["defaults", "test", "vcap"]);
}
