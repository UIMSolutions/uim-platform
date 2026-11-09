/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (AL_CONFIG_FILE or config/default.json)
///   3. environment variables (AL_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "auditlog-config"
struct AuditLogConfig {
  string serviceName = "AuditLog Service";
  string host = "0.0.0.0";
  ushort port = 8085;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/auditlog";
  /// Run retention enforcement every N minutes (0 = off).
  int retentionIntervalMinutes = 0;
  string[] retentionTenants = ["default"];
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// Apply a flat JSON object of settings.
  void apply(Json values, string source) {
    if (values.type != Json.Type.object)
      return;
    if (auto v = "serviceName" in values) serviceName = v.get!string;
    if (auto v = "host" in values) host = v.get!string;
    if (auto v = "port" in values) port = v.type == Json.Type.string ? v.get!string.to!ushort : cast(ushort) v.get!long;
    if (auto v = "logLevel" in values) logLevel = v.get!string;
    if (auto v = "storage" in values) storage = v.get!string;
    if (auto v = "dataDir" in values) dataDir = v.get!string;
    if (auto v = "defaultTenant" in values) defaultTenant = v.get!string;
    if (auto v = "odataPath" in values) odataPath = v.get!string;
    if (auto v = "frontendDir" in values) frontendDir = v.get!string;
    if (auto v = "retentionIntervalMinutes" in values)
      retentionIntervalMinutes = v.type == Json.Type.string ? v.get!string.to!int : cast(int) v.get!long;
    if (auto v = "retentionTenants" in values) {
      if (v.type == Json.Type.array) {
        retentionTenants = null;
        foreach (t; v.get!(Json[]))
          retentionTenants ~= t.get!string;
      } else if (v.type == Json.Type.string) {
        retentionTenants = v.get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
      }
    }
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  Json toJson() const {
    auto tenants = Json.emptyArray;
    foreach (t; retentionTenants)
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
      .set("retentionIntervalMinutes", retentionIntervalMinutes)
      .set("retentionTenants", tenants)
      .set("frontendDir", frontendDir)
      .set("sources", origins);
  }
}

/// Backwards compatible name.
alias SrvConfig = AuditLogConfig;

/// Load configuration with the documented precedence.
AuditLogConfig loadConfig() {
  AuditLogConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("auditlog: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("AL_SERVICE_NAME", "serviceName");
  fromEnv("AL_HOST", "host");
  fromEnv("AL_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("AL_LOG_LEVEL", "logLevel");
  fromEnv("AL_STORAGE", "storage");
  fromEnv("AL_DATA_DIR", "dataDir");
  fromEnv("AL_DEFAULT_TENANT", "defaultTenant");
  fromEnv("AL_ODATA_PATH", "odataPath");
  fromEnv("AL_RETENTION_INTERVAL", "retentionIntervalMinutes");
  fromEnv("AL_RETENTION_TENANTS", "retentionTenants");
  fromEnv("AL_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("auditlog: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "auditlog-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("auditlog: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("AL_CONFIG_FILE", "");
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
  mixin(ShowTest!("AuditLogConfig"));

  AuditLogConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "retentionTenants": "a, b"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.retentionTenants == ["a", "b"]);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "auditlog-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "auditlog-config"), "vcap");
  assert(cfg.port == 9100);
}
