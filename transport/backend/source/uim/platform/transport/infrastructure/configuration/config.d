/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (TM_CONFIG_FILE or config/default.json)
///   3. environment variables (TM_*, legacy TRANSPORT_HOST / TRANSPORT_PORT, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "transport-config"
struct TransportConfig {
  string serviceName = "Transport Management Service";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8117;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/transport";
  /// Run the auto-import worker every N minutes (0 = off).
  int autoImportIntervalMinutes = 0;
  string[] autoImportTenants = ["default"];
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// Apply a flat JSON object of settings.
  void apply(Json values, string source) {
    if (values.type != Json.Type.object)
      return;
    int toInt(Json v) {
      return v.type == Json.Type.string ? v.get!string.to!int : cast(int) v.get!long;
    }

    if (auto v = "serviceName" in values) serviceName = v.get!string;
    if (auto v = "serviceVersion" in values) serviceVersion = v.get!string;
    if (auto v = "host" in values) host = v.get!string;
    if (auto v = "port" in values) port = cast(ushort) toInt(*v);
    if (auto v = "logLevel" in values) logLevel = v.get!string;
    if (auto v = "storage" in values) storage = v.get!string;
    if (auto v = "dataDir" in values) dataDir = v.get!string;
    if (auto v = "defaultTenant" in values) defaultTenant = v.get!string;
    if (auto v = "odataPath" in values) odataPath = v.get!string;
    if (auto v = "frontendDir" in values) frontendDir = v.get!string;
    if (auto v = "autoImportIntervalMinutes" in values) autoImportIntervalMinutes = toInt(*v);
    if (auto v = "autoImportTenants" in values) {
      if (v.type == Json.Type.array) {
        autoImportTenants = null;
        foreach (t; v.get!(Json[]))
          autoImportTenants ~= t.get!string;
      } else if (v.type == Json.Type.string) {
        autoImportTenants = v.get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
      }
    }
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    auto tenants = Json.emptyArray;
    foreach (t; autoImportTenants)
      tenants ~= Json(t);
    auto origins = Json.emptyArray;
    foreach (s; sources)
      origins ~= Json(s);
    return Json.emptyObject
      .set("serviceName", serviceName)
      .set("serviceVersion", serviceVersion)
      .set("host", host)
      .set("port", port)
      .set("logLevel", logLevel)
      .set("storage", storage)
      .set("dataDir", dataDir)
      .set("defaultTenant", defaultTenant)
      .set("odataPath", odataPath)
      .set("autoImportIntervalMinutes", autoImportIntervalMinutes)
      .set("autoImportTenants", tenants)
      .set("frontendDir", frontendDir)
      .set("sources", origins);
  }
}

/// Backwards compatible name.
alias SrvConfig = TransportConfig;

/// Load configuration with the documented precedence.
TransportConfig loadConfig() {
  TransportConfig config;

  auto file = locateConfigFile();
  if (file.length > 0) {
    try
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    catch (Exception e)
      logWarn("transport: ignoring config file %s: %s", file, e.msg);
  }

  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }

  fromEnv("TRANSPORT_HOST", "host"); // legacy (k8s configmap)
  fromEnv("TRANSPORT_PORT", "port"); // legacy
  fromEnv("TM_SERVICE_NAME", "serviceName");
  fromEnv("TM_HOST", "host");
  fromEnv("TM_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("TM_LOG_LEVEL", "logLevel");
  fromEnv("TM_STORAGE", "storage");
  fromEnv("TM_DATA_DIR", "dataDir");
  fromEnv("TM_DEFAULT_TENANT", "defaultTenant");
  fromEnv("TM_ODATA_PATH", "odataPath");
  fromEnv("TM_AUTO_IMPORT_INTERVAL", "autoImportIntervalMinutes");
  fromEnv("TM_AUTO_IMPORT_TENANTS", "autoImportTenants");
  fromEnv("TM_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("transport: invalid environment configuration: %s", e.msg);
  }

  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "transport-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("transport: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("TM_CONFIG_FILE", "");
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
  mixin(ShowTest!("TransportConfig"));

  TransportConfig cfg;
  cfg.apply(parseJsonString(`{"port": "9000", "storage": "memory", "autoImportTenants": "a, b"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.autoImportTenants == ["a", "b"]);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "transport-config", "credentials": {"port": 9100}}]}`);
  cfg.apply(findServiceCredentials(vcap, "transport-config"), "vcap");
  assert(cfg.port == 9100);
}
