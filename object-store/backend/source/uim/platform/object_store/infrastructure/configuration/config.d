/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (OBJSTORE_CONFIG_FILE or config/default.json)
///   3. environment variables (OBJSTORE_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "object-store-config"
struct ObjectStoreConfig {
  string serviceName = "Object Store Service";
  string host = "0.0.0.0";
  ushort port = 8092;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots + blob files in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/object-store";
  /// REST prefix; resources below it (/api/v1/object-store/buckets, ...), content API at <restPath>/content.
  string restPath = "/api/v1/object-store";
  /// Apply the lifecycle rules every N seconds in the server (0 = off).
  int lifecycleIntervalSeconds = 3600;
  string[] lifecycleTenants = ["default"];
  /// Hyperscalers offered by this deployment.
  string[] providers = ["aws", "azure", "gcp", "alibaba"];
  string defaultRegion = "eu-central-1";
  long maxObjectSize = 64L * 1024 * 1024;
  int maxBucketsPerTenant = 100;
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// The storage limits as a domain value.
  StorageLimits limits() const {
    StorageLimits l;
    l.maxObjectSize = maxObjectSize;
    l.maxBucketsPerTenant = maxBucketsPerTenant;
    l.defaultRegion = defaultRegion;
    return l;
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
    if (auto v = "restPath" in values) restPath = jsonText(*v);
    if (auto v = "frontendDir" in values) frontendDir = jsonText(*v);
    if (auto v = "lifecycleIntervalSeconds" in values)
      lifecycleIntervalSeconds = cast(int) jsonLong(*v, lifecycleIntervalSeconds);
    if (auto v = "lifecycleTenants" in values) lifecycleTenants = jsonStrings(*v);
    if (auto v = "providers" in values) providers = jsonStrings(*v);
    if (auto v = "defaultRegion" in values) defaultRegion = jsonText(*v);
    if (auto v = "maxObjectSize" in values) maxObjectSize = jsonLong(*v, maxObjectSize);
    if (auto v = "maxBucketsPerTenant" in values) maxBucketsPerTenant = cast(int) jsonLong(*v, maxBucketsPerTenant);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  /// The configured providers as enum values (unknown names are ignored).
  IaasProvider[] enabledProviders() const {
    IaasProvider[] result;
    foreach (p; providers)
      if (isEnumText!IaasProvider(p))
        result ~= parseEnum!IaasProvider(p, IaasProvider.aws);
    return result;
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
      .set("lifecycleIntervalSeconds", lifecycleIntervalSeconds)
      .set("lifecycleTenants", list(lifecycleTenants))
      .set("providers", list(providers))
      .set("defaultRegion", defaultRegion)
      .set("maxObjectSize", maxObjectSize)
      .set("maxBucketsPerTenant", maxBucketsPerTenant)
      .set("frontendDir", frontendDir)
      .set("sources", list(sources));
  }
}

/// Load configuration with the documented precedence.
ObjectStoreConfig loadConfig() {
  ObjectStoreConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("object-store: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("OBJSTORE_SERVICE_NAME", "serviceName");
  fromEnv("OBJSTORE_HOST", "host");
  fromEnv("OBJSTORE_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("OBJSTORE_LOG_LEVEL", "logLevel");
  fromEnv("OBJSTORE_STORAGE", "storage");
  fromEnv("OBJSTORE_DATA_DIR", "dataDir");
  fromEnv("OBJSTORE_DEFAULT_TENANT", "defaultTenant");
  fromEnv("OBJSTORE_ODATA_PATH", "odataPath");
  fromEnv("OBJSTORE_REST_PATH", "restPath");
  fromEnv("OBJSTORE_LIFECYCLE_INTERVAL", "lifecycleIntervalSeconds");
  fromEnv("OBJSTORE_LIFECYCLE_TENANTS", "lifecycleTenants");
  fromEnv("OBJSTORE_PROVIDERS", "providers");
  fromEnv("OBJSTORE_DEFAULT_REGION", "defaultRegion");
  fromEnv("OBJSTORE_MAX_OBJECT_SIZE", "maxObjectSize");
  fromEnv("OBJSTORE_MAX_BUCKETS", "maxBucketsPerTenant");
  fromEnv("OBJSTORE_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("object-store: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "object-store-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("object-store: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("OBJSTORE_CONFIG_FILE", "");
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
  mixin(ShowTest!("ObjectStoreConfig"));

  ObjectStoreConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "lifecycleTenants": "a, b",
    "providers": "aws,gcp,nope", "maxObjectSize": "1024", "defaultRegion": "us-east-1"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.lifecycleTenants == ["a", "b"]);
  assert(cfg.enabledProviders == [IaasProvider.aws, IaasProvider.gcp]);
  assert(cfg.limits.maxObjectSize == 1024 && cfg.limits.defaultRegion == "us-east-1");

  auto vcap = parseJsonString(`{"user-provided": [{"name": "object-store-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "object-store-config"), "vcap");
  assert(cfg.port == 9100);
}
