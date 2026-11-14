/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.configuration.config;

import std.file : exists, readText, thisExePath;
import std.path : buildPath, dirName;
import std.process : environment;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Default signing secret — refused outside of development (see isInsecure).
enum defaultJwtSecret = "change-me-in-production-use-env-var";

/// Type-safe service configuration.
///
/// Precedence (lowest → highest):
///   1. compiled defaults (this struct)
///   2. config file  (IAS_CONFIG_FILE or config/default.json)
///   3. environment variables (IAS_*, PORT)
///   4. VCAP_SERVICES — credentials of a bound service named / tagged
///      "identity-authentication-config"
struct IdentityConfig {
  string serviceName = "Identity Authentication Service";
  string host = "0.0.0.0";
  ushort port = 8125;
  string logLevel = "info";
  /// "memory" (volatile) or "file" (JSON snapshots in dataDir, shared by server/CLI/GUI)
  string storage = "file";
  string dataDir = "data";
  string defaultTenant = "default";
  string apiPath = "/api/v1";
  string restPath = "/rest/v1/identity-authentication";
  string odataPath = "/odata/v4/identity-authentication";
  /// Serve the Fiori app from this directory at "/" (local development; "" = off).
  string frontendDir = "../frontend";

  // ── security ──────────────────────────────────────────────────────────
  string issuer = "uim-identity-authentication";
  string jwtSecret = defaultJwtSecret;
  int sessionTimeoutMinutes = 480;
  int accessTokenMinutes = 60;
  int idTokenMinutes = 60;
  int refreshTokenHours = 24;
  int maxFailedLogins = 5;
  int passwordIterations = 60_000;
  int passwordMinLength = 8;
  /// POST one-time codes to this URL ({"channel","destination","message"}); "" = log only.
  string otpWebhookUrl;

  // ── background cleanup of expired sessions / tokens ──────────────────
  int cleanupIntervalMinutes = 0;
  string[] cleanupTenants = ["default"];

  /// Where the values came from (for diagnostics).
  string[] sources = ["defaults"];

  /// Apply a flat JSON object of settings.
  void apply(Json values, string source) {
    if (values.type != Json.Type.object)
      return;

    int asInt(Json v) {
      return v.type == Json.Type.string ? v.get!string.to!int : cast(int) v.get!long;
    }

    string[] asList(Json v) {
      if (v.type == Json.Type.array)
        return v.get!(Json[]).map!(t => t.get!string).array;
      return v.get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
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
    if (auto v = "issuer" in values) issuer = v.get!string;
    if (auto v = "jwtSecret" in values) jwtSecret = v.get!string;
    if (auto v = "sessionTimeoutMinutes" in values) sessionTimeoutMinutes = asInt(*v);
    if (auto v = "accessTokenMinutes" in values) accessTokenMinutes = asInt(*v);
    if (auto v = "idTokenMinutes" in values) idTokenMinutes = asInt(*v);
    if (auto v = "refreshTokenHours" in values) refreshTokenHours = asInt(*v);
    if (auto v = "maxFailedLogins" in values) maxFailedLogins = asInt(*v);
    if (auto v = "passwordIterations" in values) passwordIterations = asInt(*v);
    if (auto v = "passwordMinLength" in values) passwordMinLength = asInt(*v);
    if (auto v = "otpWebhookUrl" in values) otpWebhookUrl = v.get!string;
    if (auto v = "cleanupIntervalMinutes" in values) cleanupIntervalMinutes = asInt(*v);
    if (auto v = "cleanupTenants" in values) cleanupTenants = asList(*v);
    sources ~= source;
  }

  bool usesFileStorage() const {
    return storage == "file";
  }

  /// True while the token signing secret is the compiled-in default.
  bool isInsecure() const {
    return jwtSecret == defaultJwtSecret || jwtSecret.length < 16;
  }

  /// Business parameters for the use cases.
  AuthenticationSettings settings() const {
    AuthenticationSettings s;
    s.issuer = issuer;
    s.sessionTimeoutMinutes = sessionTimeoutMinutes;
    s.maxFailedLogins = maxFailedLogins;
    s.accessTokenMinutes = accessTokenMinutes;
    s.idTokenMinutes = idTokenMinutes;
    s.refreshTokenHours = refreshTokenHours;
    s.passwordMinLength = passwordMinLength;
    return s;
  }

  /// Effective configuration — secrets masked.
  Json toJson() const {
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
      .set("issuer", issuer)
      .set("jwtSecret", isInsecure ? "<default — set IAS_JWT_SECRET>" : "<set>")
      .set("sessionTimeoutMinutes", sessionTimeoutMinutes)
      .set("accessTokenMinutes", accessTokenMinutes)
      .set("idTokenMinutes", idTokenMinutes)
      .set("refreshTokenHours", refreshTokenHours)
      .set("maxFailedLogins", maxFailedLogins)
      .set("passwordIterations", passwordIterations)
      .set("passwordMinLength", passwordMinLength)
      .set("otpWebhookUrl", otpWebhookUrl)
      .set("cleanupIntervalMinutes", cleanupIntervalMinutes)
      .set("cleanupTenants", cleanupTenants.map!(s => Json(s)).array.toJson)
      .set("sources", sources.map!(s => Json(s)).array.toJson);
  }
}

/// Backwards compatible name.
alias SrvConfig = IdentityConfig;

/// Load configuration with the documented precedence.
IdentityConfig loadConfig() {
  IdentityConfig config;

  // 2. config file
  auto file = locateConfigFile();
  if (file.length > 0) {
    try {
      config.apply(parseJsonString((() @trusted => readText(file))()), file);
    } catch (Exception e) {
      logWarn("identity-authentication: ignoring config file %s: %s", file, e.msg);
    }
  }

  // 3. environment variables
  auto env = Json.emptyObject;
  void fromEnv(string variable, string key) {
    auto value = environment.get(variable, "");
    if (value.length > 0)
      env[key] = value;
  }

  fromEnv("IAS_SERVICE_NAME", "serviceName");
  fromEnv("IAS_HOST", "host");
  fromEnv("IAS_PORT", "port");
  fromEnv("PORT", "port"); // Cloud Foundry
  fromEnv("IAS_LOG_LEVEL", "logLevel");
  fromEnv("IAS_STORAGE", "storage");
  fromEnv("IAS_DATA_DIR", "dataDir");
  fromEnv("IAS_DEFAULT_TENANT", "defaultTenant");
  fromEnv("IAS_ODATA_PATH", "odataPath");
  fromEnv("IAS_FRONTEND_DIR", "frontendDir");
  fromEnv("IAS_ISSUER", "issuer");
  fromEnv("IAS_JWT_SECRET", "jwtSecret");
  fromEnv("IAS_SESSION_TIMEOUT", "sessionTimeoutMinutes");
  fromEnv("IAS_ACCESS_TOKEN_MINUTES", "accessTokenMinutes");
  fromEnv("IAS_REFRESH_TOKEN_HOURS", "refreshTokenHours");
  fromEnv("IAS_MAX_FAILED_LOGINS", "maxFailedLogins");
  fromEnv("IAS_PASSWORD_ITERATIONS", "passwordIterations");
  fromEnv("IAS_OTP_WEBHOOK_URL", "otpWebhookUrl");
  fromEnv("IAS_CLEANUP_INTERVAL", "cleanupIntervalMinutes");
  fromEnv("IAS_CLEANUP_TENANTS", "cleanupTenants");
  try {
    if (env.length > 0)
      config.apply(env, "environment");
  } catch (Exception e) {
    logWarn("identity-authentication: invalid environment configuration: %s", e.msg);
  }

  // 4. VCAP_SERVICES
  auto vcap = environment.get("VCAP_SERVICES", "");
  if (vcap.length > 0) {
    try {
      auto credentials = findServiceCredentials(parseJsonString(vcap), "identity-authentication-config");
      if (credentials.type == Json.Type.object)
        config.apply(credentials, "VCAP_SERVICES");
    } catch (Exception e) {
      logWarn("identity-authentication: cannot parse VCAP_SERVICES: %s", e.msg);
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
      bool match = fieldString(instance, "name") == nameOrTag
        || fieldString(instance, "binding_name") == nameOrTag
        || fieldStrings(instance, "tags").canFind(nameOrTag);
      if (match && "credentials" in instance)
        return instance["credentials"];
    }
  }
  return Json.undefined;
}

private string locateConfigFile() {
  auto explicit = environment.get("IAS_CONFIG_FILE", "");
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
  mixin(ShowTest!("IdentityConfig"));

  IdentityConfig cfg;
  assert(cfg.isInsecure);
  cfg.apply(parseJsonString(`{"port": 9000, "storage": "memory", "cleanupTenants": "a, b", "maxFailedLogins": "3"}`), "test");
  assert(cfg.port == 9000 && !cfg.usesFileStorage);
  assert(cfg.cleanupTenants == ["a", "b"] && cfg.settings.maxFailedLogins == 3);

  auto vcap = parseJsonString(`{"user-provided": [{"name": "identity-authentication-config",
    "credentials": {"jwtSecret": "0123456789abcdef0123"}}]}`);
  cfg.apply(findServiceCredentials(vcap, "identity-authentication-config"), "vcap");
  assert(!cfg.isInsecure);
  assert(cfg.toJson["jwtSecret"].get!string == "<set>");
  assert(cfg.sources == ["defaults", "test", "vcap"]);
}
