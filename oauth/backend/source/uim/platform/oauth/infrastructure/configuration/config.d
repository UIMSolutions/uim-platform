/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → OAUTH_<KEY> environment variables (e.g. OAUTH_PORT, OAUTH_SIGNING_SECRET)
///   → Cloud Foundry (PORT, VCAP_APPLICATION, VCAP_SERVICES: credentials of
///     the user-provided service "oauth-config")
///   → explicit overrides (CLI/GUI options)
module uim.platform.oauth.infrastructure.configuration.config;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "OAUTH";

/// Name of the optional user-provided service with runtime overrides.
enum string configServiceName = "oauth-config";

struct OAuthConfig {
  string serviceName = "uim-oauth";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8114;
  string storage = "memory"; /// memory | file
  string dataFile = "data/oauth.json";
  string defaultTenant = "default";
  string restPath = "/api/v1/oauth";
  string odataPath = "/odata/v4/oauth";
  string oauthPath = "/oauth"; /// protocol endpoints: <oauthPath>/token, /authorize, /introspect, /revoke
  string issuer; /// "iss" of issued tokens; default: publicUrl (CF) or http://localhost:<port>
  size_t maxPageSize = 200;
  bool requireAuthentication;
  string jwtSecret; /// HS256 secret for the management APIs (non-BTP)
  string signingSecret; /// HS256 key for issued tokens; "" = generated once and kept in the store
  long authorizationCodeValiditySeconds = 300;
  /// Development only: accept the resource owner of /authorize from the
  /// X-User-Id header (or an unverified token) instead of a verified user token.
  bool trustUserHeader;
  string frontendDir = "../frontend";
  uint purgeIntervalSeconds; /// 0 = no background purge of expired tokens
  string[] purgeTenants = ["default"];

  Json raw; /// the merged document (incl. "services" from VCAP_SERVICES)
  string[] sources; /// where values came from (for diagnostics)

  /// Effective configuration with secrets masked.
  Json toMaskedJson() @trusted {
    auto j = raw.clone;
    foreach (key; ["jwtSecret", "signingSecret"])
      if (key in j && j[key].type == Json.Type.string && j[key].get!string.length)
        j[key] = "***";
    if ("services" in j)
      j["services"] = "*** (" ~ j["services"].length.to!string ~ " bound services)";
    j["issuer"] = issuer;
    return j;
  }
}

/// Built-in defaults as JSON (also the set of keys env vars may override).
Json defaultConfigJson() {
  OAuthConfig d;
  auto j = Json.emptyObject;
  j["serviceName"] = d.serviceName;
  j["serviceVersion"] = d.serviceVersion;
  j["host"] = d.host;
  j["port"] = d.port;
  j["storage"] = d.storage;
  j["dataFile"] = d.dataFile;
  j["defaultTenant"] = d.defaultTenant;
  j["restPath"] = d.restPath;
  j["odataPath"] = d.odataPath;
  j["oauthPath"] = d.oauthPath;
  j["issuer"] = "";
  j["maxPageSize"] = d.maxPageSize;
  j["requireAuthentication"] = d.requireAuthentication;
  j["jwtSecret"] = "";
  j["signingSecret"] = "";
  j["authorizationCodeValiditySeconds"] = d.authorizationCodeValiditySeconds;
  j["trustUserHeader"] = d.trustUserHeader;
  j["frontendDir"] = d.frontendDir;
  j["purgeIntervalSeconds"] = d.purgeIntervalSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.purgeTenants)
    tenants ~= Json(t);
  j["purgeTenants"] = tenants;
  return j;
}

/// Load the layered configuration.
OAuthConfig loadOAuthConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  auto provided = serviceCredentials(j, configServiceName);
  if (provided.isObject)
    foreach (k, v; provided.get!(Json[string]))
      j[k] = v;
  foreach (k, v; overrides)
    j[k] = v;

  OAuthConfig c;
  c.raw = j;
  c.sources = ["defaults"];
  if (exists(buildPath(configDir, "default.json")))
    c.sources ~= buildPath(configDir, "default.json");
  c.sources ~= configEnvPrefix ~ "_* env";
  if (provided.isObject)
    c.sources ~= "VCAP_SERVICES " ~ configServiceName;
  if (overrides.length)
    c.sources ~= "command line";

  c.serviceName = text(j, "serviceName", c.serviceName);
  c.serviceVersion = text(j, "serviceVersion", c.serviceVersion);
  c.host = text(j, "host", c.host);
  c.port = cast(ushort) number(j, "port", c.port);
  c.storage = text(j, "storage", c.storage);
  c.dataFile = text(j, "dataFile", c.dataFile);
  c.defaultTenant = text(j, "defaultTenant", c.defaultTenant);
  c.restPath = "/" ~ text(j, "restPath", c.restPath).strip("/");
  c.odataPath = "/" ~ text(j, "odataPath", c.odataPath).strip("/");
  c.oauthPath = "/" ~ text(j, "oauthPath", c.oauthPath).strip("/");
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.requireAuthentication = flag(j, "requireAuthentication", c.requireAuthentication);
  c.jwtSecret = text(j, "jwtSecret", "");
  c.signingSecret = text(j, "signingSecret", "");
  c.authorizationCodeValiditySeconds = number(j, "authorizationCodeValiditySeconds", c.authorizationCodeValiditySeconds);
  c.trustUserHeader = flag(j, "trustUserHeader", c.trustUserHeader);
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.purgeIntervalSeconds = cast(uint) number(j, "purgeIntervalSeconds", c.purgeIntervalSeconds);
  if ("purgeTenants" in j && j["purgeTenants"].type == Json.Type.array) {
    c.purgeTenants = null;
    foreach (t; j["purgeTenants"])
      if (t.type == Json.Type.string)
        c.purgeTenants ~= t.get!string;
  }
  c.issuer = text(j, "issuer", "").stripRight("/");
  if (c.issuer.length == 0)
    c.issuer = text(j, "publicUrl", "http://localhost:" ~ c.port.to!string).stripRight("/");
  validateConfig(c);
  return c;
}

void validateConfig(const OAuthConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.restPath != c.odataPath && c.restPath != c.oauthPath && c.odataPath != c.oauthPath,
    "restPath, odataPath and oauthPath must differ");
  enforce(c.signingSecret.length == 0 || c.signingSecret.length >= 32, "signingSecret must have at least 32 characters");
  enforce(c.authorizationCodeValiditySeconds >= 30 && c.authorizationCodeValiditySeconds <= 600,
    "authorizationCodeValiditySeconds must be between 30 and 600");
  enforce(isHttpUrl(c.issuer), "issuer must be an http(s) URL");
}

private string text(Json j, string key, string fallback) {
  return key in j && j[key].type == Json.Type.string ? j[key].get!string : fallback;
}

private long number(Json j, string key, long fallback) {
  if (key !in j)
    return fallback;
  if (j[key].type == Json.Type.int_)
    return j[key].get!long;
  if (j[key].type == Json.Type.float_)
    return cast(long) j[key].get!double;
  return fallback;
}

private bool flag(Json j, string key, bool fallback) {
  return key in j && j[key].type == Json.Type.bool_ ? j[key].get!bool : fallback;
}

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["port"] = 9001;
  o["odataPath"] = "odata/v4/o/";
  o["signingSecret"] = "0123456789abcdef0123456789abcdef";
  auto c = loadOAuthConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/o");
  assert(c.issuer == "http://localhost:9001");
  auto masked = c.toMaskedJson();
  assert(masked["port"].get!long == 9001 && masked["signingSecret"].get!string == "***");

  o["signingSecret"] = "short";
  bool failed;
  try
    loadOAuthConfig(o, "/nonexistent");
  catch (Exception)
    failed = true;
  assert(failed);
}
