/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (APPLICATION_STUDIO_CONFIG_FILE or config/default.json)
///   3. environment variables (APPLICATION_STUDIO_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "application-studio-config"
struct StudioConfig {
  string serviceName = "Application Studio Service";
  string host = "0.0.0.0";
  ushort port = 8111;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/application-studio";
  /// Run the reconciler every N seconds in the server (0 = off).
  int reconcileIntervalSeconds = 10;
  string[] reconcileTenants = ["default"];
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
    if (auto v = "reconcileIntervalSeconds" in values)
      reconcileIntervalSeconds = cast(int) jsonLong(*v, reconcileIntervalSeconds);
    if (auto v = "reconcileTenants" in values)
      reconcileTenants = jsonStrings(*v);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    auto tenants = Json.emptyArray;
    foreach (t; reconcileTenants)
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
      .set("reconcileIntervalSeconds", reconcileIntervalSeconds)
      .set("reconcileTenants", tenants)
      .set("frontendDir", frontendDir)
      .set("sources", origins);
  }
}

/// Load configuration with the documented precedence.
StudioConfig loadConfig() {
  StudioConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("studio: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("APPLICATION_STUDIO_SERVICE_NAME", "serviceName");
  fromEnv("APPLICATION_STUDIO_HOST", "host");
  fromEnv("APPLICATION_STUDIO_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("APPLICATION_STUDIO_LOG_LEVEL", "logLevel");
  fromEnv("APPLICATION_STUDIO_STORAGE", "storage");
  fromEnv("APPLICATION_STUDIO_DATA_DIR", "dataDir");
  fromEnv("APPLICATION_STUDIO_DEFAULT_TENANT", "defaultTenant");
  fromEnv("APPLICATION_STUDIO_ODATA_PATH", "odataPath");
  fromEnv("APPLICATION_STUDIO_RECONCILE_INTERVAL", "reconcileIntervalSeconds");
  fromEnv("APPLICATION_STUDIO_RECONCILE_TENANTS", "reconcileTenants");
  fromEnv("APPLICATION_STUDIO_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("studio: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "application-studio-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("studio: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("APPLICATION_STUDIO_CONFIG_FILE", "");
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
  mixin(ShowTest!("StudioConfig"));

  StudioConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "reconcileTenants": "a, b"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.reconcileTenants == ["a", "b"]);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "application-studio-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "application-studio-config"), "vcap");
  assert(cfg.port == 9100);
}
