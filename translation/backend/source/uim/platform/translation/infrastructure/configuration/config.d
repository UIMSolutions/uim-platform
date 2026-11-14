/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (TRANSLATION_CONFIG_FILE or config/default.json)
///   3. environment variables (TRANSLATION_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named/tagged "translation-config"
struct TranslationConfig {
  string serviceName = "Translation Hub Service";
  string host = "0.0.0.0";
  ushort port = 8096;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string odataPath = "/odata/v4/translation";
  /// REST prefix; the resources are served below it (/api/v1/translation/projects, ...).
  string restPath = "/api/v1/translation";
  /// Process pending jobs every N seconds in the server (0 = off).
  int jobIntervalSeconds = 5;
  string[] jobTenants = ["default"];
  /// Providers that are configured / reachable (others report "not available").
  string[] providers = ["mltr", "machineMt", "companyMltr", "llm"];
  string defaultProvider = "machineMt";
  int maxTextLength = 5000;
  int maxBatchSize = 100;
  int maxDocumentLength = 1_000_000;
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// The service limits as a domain value.
  TranslationPolicy policy() const {
    TranslationPolicy p;
    p.maxTextLength = maxTextLength;
    p.maxBatchSize = maxBatchSize;
    p.maxDocumentLength = maxDocumentLength;
    p.defaultProvider = parseEnum!TranslationProvider(defaultProvider, TranslationProvider.machineMt);
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
    if (auto v = "restPath" in values) restPath = jsonText(*v);
    if (auto v = "frontendDir" in values) frontendDir = jsonText(*v);
    if (auto v = "jobIntervalSeconds" in values) jobIntervalSeconds = cast(int) jsonLong(*v, jobIntervalSeconds);
    if (auto v = "jobTenants" in values) jobTenants = jsonStrings(*v);
    if (auto v = "providers" in values) providers = jsonStrings(*v);
    if (auto v = "defaultProvider" in values) defaultProvider = jsonText(*v);
    if (auto v = "maxTextLength" in values) maxTextLength = cast(int) jsonLong(*v, maxTextLength);
    if (auto v = "maxBatchSize" in values) maxBatchSize = cast(int) jsonLong(*v, maxBatchSize);
    if (auto v = "maxDocumentLength" in values) maxDocumentLength = cast(int) jsonLong(*v, maxDocumentLength);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  /// The configured providers as enum values (unknown names are ignored).
  TranslationProvider[] enabledProviders() const {
    TranslationProvider[] result;
    foreach (p; providers)
      if (isEnumText!TranslationProvider(p))
        result ~= parseEnum!TranslationProvider(p, TranslationProvider.machineMt);
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
      .set("jobIntervalSeconds", jobIntervalSeconds)
      .set("jobTenants", list(jobTenants))
      .set("providers", list(providers))
      .set("defaultProvider", defaultProvider)
      .set("maxTextLength", maxTextLength)
      .set("maxBatchSize", maxBatchSize)
      .set("maxDocumentLength", maxDocumentLength)
      .set("frontendDir", frontendDir)
      .set("sources", list(sources));
  }
}

/// Load configuration with the documented precedence.
TranslationConfig loadConfig() {
  TranslationConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("translation: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }
  fromEnv("TRANSLATION_SERVICE_NAME", "serviceName");
  fromEnv("TRANSLATION_HOST", "host");
  fromEnv("TRANSLATION_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("TRANSLATION_LOG_LEVEL", "logLevel");
  fromEnv("TRANSLATION_STORAGE", "storage");
  fromEnv("TRANSLATION_DATA_DIR", "dataDir");
  fromEnv("TRANSLATION_DEFAULT_TENANT", "defaultTenant");
  fromEnv("TRANSLATION_ODATA_PATH", "odataPath");
  fromEnv("TRANSLATION_REST_PATH", "restPath");
  fromEnv("TRANSLATION_JOB_INTERVAL", "jobIntervalSeconds");
  fromEnv("TRANSLATION_JOB_TENANTS", "jobTenants");
  fromEnv("TRANSLATION_PROVIDERS", "providers");
  fromEnv("TRANSLATION_DEFAULT_PROVIDER", "defaultProvider");
  fromEnv("TRANSLATION_MAX_TEXT_LENGTH", "maxTextLength");
  fromEnv("TRANSLATION_MAX_BATCH_SIZE", "maxBatchSize");
  fromEnv("TRANSLATION_MAX_DOCUMENT_LENGTH", "maxDocumentLength");
  fromEnv("TRANSLATION_FRONTEND_DIR", "frontendDir");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("translation: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "translation-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("translation: cannot parse VCAP_SERVICES: %s", e.msg);
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
  auto explicit = environment.get("TRANSLATION_CONFIG_FILE", "");
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
  mixin(ShowTest!("TranslationConfig"));

  TranslationConfig cfg;
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "jobTenants": "a, b", "providers": "mltr,llm,nope",
    "defaultProvider": "llm", "maxBatchSize": "10"}`), "test");
  assert(cfg.port == 9000);
  assert(!cfg.usesFileStorage);
  assert(cfg.jobTenants == ["a", "b"]);
  assert(cfg.enabledProviders == [TranslationProvider.mltr, TranslationProvider.llm]);
  assert(cfg.policy.defaultProvider == TranslationProvider.llm && cfg.policy.maxBatchSize == 10);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "translation-config", "credentials": {"port": "9100"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "translation-config"), "vcap");
  assert(cfg.port == 9100);
}
