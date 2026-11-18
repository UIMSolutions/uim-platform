/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (IPS_CONFIG_FILE or config/default.json)
///   3. environment variables (IPS_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "identity-provisioning-config"
struct ProvisioningConfig {
  string serviceName = "Identity Provisioning Service";
  string host = "0.0.0.0";
  ushort port = 8093;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/identity-provisioning";
  /// REST prefix; resources are served below it (/api/v1/source-systems, ...).
  string restPath = "/api/v1";
  /// Run due scheduled jobs every N seconds in the server (0 = off).
  int schedulerIntervalSeconds = 30;
  string[] schedulerTenants = ["default"];
  /// The scheduler purges log entries older than N days (0 = keep forever).
  int logRetentionDays = 30;
  /// Create demo systems, transformations and jobs in an empty default tenant.
  bool demoData = false;
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

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
    if (auto v = "restPath" in values) restPath = jsonText(*v);
    if (auto v = "schedulerIntervalSeconds" in values) schedulerIntervalSeconds = cast(int) jsonLong(*v, schedulerIntervalSeconds);
    if (auto v = "schedulerTenants" in values) schedulerTenants = jsonStrings(*v);
    if (auto v = "logRetentionDays" in values) logRetentionDays = cast(int) jsonLong(*v, logRetentionDays);
    if (auto v = "demoData" in values) demoData = jsonBool(*v, demoData);
    if (auto v = "frontendDir" in values) frontendDir = jsonText(*v);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    Json list(const string[] items) {
      auto arr = Json.emptyArray;
      foreach (i; items)
        arr ~= Json(i);
      return arr;
    }

    return Json.emptyObject
      .set("serviceName", serviceName)
      .set("host", host)
      .set("port", port)
      .set("logLevel", logLevel)
      .set("storage", storage)
      .set("dataDir", dataDir)
      .set("defaultTenant", defaultTenant)
      .set("odataPath", odataPath)
      .set("restPath", restPath)
      .set("schedulerIntervalSeconds", schedulerIntervalSeconds)
      .set("schedulerTenants", list(schedulerTenants))
      .set("logRetentionDays", logRetentionDays)
      .set("demoData", demoData)
      .set("frontendDir", frontendDir)
      .set("sources", list(sources));
  }
}

/// Load configuration with the documented precedence.
ProvisioningConfig loadConfig() {
  ProvisioningConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("identity-provisioning: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("IPS_SERVICE_NAME", "serviceName");
  fromEnv("IPS_HOST", "host");
  fromEnv("IPS_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("IPS_LOG_LEVEL", "logLevel");
  fromEnv("IPS_STORAGE", "storage");
  fromEnv("IPS_DATA_DIR", "dataDir");
  fromEnv("IPS_DEFAULT_TENANT", "defaultTenant");
  fromEnv("IPS_ODATA_PATH", "odataPath");
  fromEnv("IPS_REST_PATH", "restPath");
  fromEnv("IPS_SCHEDULER_INTERVAL", "schedulerIntervalSeconds");
  fromEnv("IPS_SCHEDULER_TENANTS", "schedulerTenants");
  fromEnv("IPS_LOG_RETENTION_DAYS", "logRetentionDays");
  fromEnv("IPS_DEMO_DATA", "demoData");
  fromEnv("IPS_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("identity-provisioning: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "identity-provisioning-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("identity-provisioning: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("IPS_CONFIG_FILE", "");
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
  mixin(ShowTest!("ProvisioningConfig"));

  ProvisioningConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "schedulerTenants": "a, b",
    "schedulerIntervalSeconds": "10", "demoData": "yes"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.schedulerTenants == ["a", "b"]);
  assert(cfg.schedulerIntervalSeconds == 10 && cfg.demoData);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "identity-provisioning-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "identity-provisioning-config"), "vcap");
  assert(cfg.port == 9100);
  assert(cfg.sources == ["defaults", "test", "vcap"]);
}
