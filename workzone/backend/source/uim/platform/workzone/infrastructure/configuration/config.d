/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (WORKZONE_CONFIG_FILE or config/default.json)
///   3. environment variables (WORKZONE_*, legacy WZ_HOST / WZ_PORT, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "workzone-config"
struct WorkzoneConfig {
  string serviceName = "Work Zone Service";
  string host = "0.0.0.0";
  ushort port = 8084;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/workzone";
  /// Run housekeeping every N seconds in the server (0 = off).
  int housekeepingIntervalSeconds = 30;
  string[] housekeepingTenants = ["default"];
  /// Install the predefined roles, themes, templates and tags into the default tenant on start.
  bool seedContent = true;
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
    if (auto v = "frontendDir" in values) frontendDir = jsonText(*v);
    if (auto v = "housekeepingIntervalSeconds" in values)
      housekeepingIntervalSeconds = cast(int) jsonLong(*v, housekeepingIntervalSeconds);
    if (auto v = "housekeepingTenants" in values)
      housekeepingTenants = jsonStrings(*v);
    if (auto v = "seedContent" in values)
      seedContent = jsonBool(*v, seedContent);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    auto tenants = Json.emptyArray;
    foreach (t; housekeepingTenants)
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
      .set("housekeepingIntervalSeconds", housekeepingIntervalSeconds)
      .set("housekeepingTenants", tenants)
      .set("seedContent", seedContent)
      .set("frontendDir", frontendDir)
      .set("sources", origins);
  }
}

/// Load configuration with the documented precedence.
WorkzoneConfig loadConfig() {
  WorkzoneConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("workzone: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("WZ_HOST", "host"); // legacy names of the previous version
  fromEnv("WZ_PORT", "port");
  fromEnv("WORKZONE_SERVICE_NAME", "serviceName");
  fromEnv("WORKZONE_HOST", "host");
  fromEnv("WORKZONE_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("WORKZONE_LOG_LEVEL", "logLevel");
  fromEnv("WORKZONE_STORAGE", "storage");
  fromEnv("WORKZONE_DATA_DIR", "dataDir");
  fromEnv("WORKZONE_DEFAULT_TENANT", "defaultTenant");
  fromEnv("WORKZONE_ODATA_PATH", "odataPath");
  fromEnv("WORKZONE_HOUSEKEEPING_INTERVAL", "housekeepingIntervalSeconds");
  fromEnv("WORKZONE_HOUSEKEEPING_TENANTS", "housekeepingTenants");
  fromEnv("WORKZONE_SEED_CONTENT", "seedContent");
  fromEnv("WORKZONE_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("workzone: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "workzone-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("workzone: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("WORKZONE_CONFIG_FILE", "");
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
  mixin(ShowTest!("WorkzoneConfig"));

  WorkzoneConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "housekeepingTenants": "a, b", "seedContent": "off"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.housekeepingTenants == ["a", "b"]);
  assert(!cfg.seedContent);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "workzone-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "workzone-config"), "vcap");
  assert(cfg.port == 9100);
}
