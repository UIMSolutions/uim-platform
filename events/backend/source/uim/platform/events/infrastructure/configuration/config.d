/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed configuration.
///
/// Precedence (lowest → highest):
///   built-in defaults → config/default.json → config/<UIM_PROFILE>.json
///   → EVENT_MESH_<KEY> environment variables (e.g. EVENT_MESH_PORT,
///     EVENT_MESH_DATA_FILE) → Cloud Foundry (PORT, VCAP_SERVICES)
///   → explicit overrides (CLI/GUI options)
module uim.platform.events.infrastructure.configuration.config;

import uim.platform.events;

mixin(ShowModule!());

@safe:

enum string configEnvPrefix = "EVENT_MESH";

struct EventsConfig {
  string serviceName = "uim-event-mesh";
  string serviceVersion = "2.0.0";
  string host = "0.0.0.0";
  ushort port = 8109;
  string storage = "memory"; /// memory | file
  string dataFile = "data/event-mesh.json";
  string defaultTenant = "default";
  string restPath = "/api/v1/event-mesh";
  string odataPath = "/odata/v4/event-mesh";
  size_t maxPageSize = 200;
  bool requireAuthentication;
  string jwtSecret;
  string frontendDir = "../frontend";
  uint deliveryIntervalSeconds; /// 0 = no background webhook delivery
  uint webhookTimeoutSeconds = 10;
  string[] deliveryTenants = ["default"];

  Json raw; /// the merged document (incl. "services" from VCAP_SERVICES)
  string[] sources; /// where values came from (for diagnostics)

  /// Effective configuration with secrets masked.
  Json toMaskedJson() @trusted {
    auto j = raw.clone;
    if ("jwtSecret" in j && j["jwtSecret"].type == Json.Type.string && j["jwtSecret"].get!string.length)
      j["jwtSecret"] = "***";
    if ("services" in j)
      j["services"] = "*** (" ~ j["services"].length.to!string ~ " bound services)";
    return j;
  }
}

/// Built-in defaults as JSON (also the set of keys env vars may override).
Json defaultConfigJson() {
  EventsConfig d;
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
  j["maxPageSize"] = d.maxPageSize;
  j["requireAuthentication"] = d.requireAuthentication;
  j["jwtSecret"] = d.jwtSecret;
  j["frontendDir"] = d.frontendDir;
  j["deliveryIntervalSeconds"] = d.deliveryIntervalSeconds;
  j["webhookTimeoutSeconds"] = d.webhookTimeoutSeconds;
  auto tenants = Json.emptyArray;
  foreach (t; d.deliveryTenants)
    tenants ~= Json(t);
  j["deliveryTenants"] = tenants;
  return j;
}

/// Load the layered configuration.
EventsConfig loadEventsConfig(Json[string] overrides = null, string configDir = "config") @trusted {
  import std.file : exists;
  import std.path : buildPath;

  auto j = loadServiceConfiguration(configEnvPrefix, defaultConfigJson(), configDir);
  foreach (k, v; overrides)
    j[k] = v;

  EventsConfig c;
  c.raw = j;
  c.sources = ["defaults"];
  if (exists(buildPath(configDir, "default.json")))
    c.sources ~= buildPath(configDir, "default.json");
  c.sources ~= configEnvPrefix ~ "_* env";
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
  c.maxPageSize = cast(size_t) number(j, "maxPageSize", c.maxPageSize);
  c.requireAuthentication = flag(j, "requireAuthentication", c.requireAuthentication);
  c.jwtSecret = text(j, "jwtSecret", c.jwtSecret);
  c.frontendDir = text(j, "frontendDir", c.frontendDir);
  c.deliveryIntervalSeconds = cast(uint) number(j, "deliveryIntervalSeconds", c.deliveryIntervalSeconds);
  c.webhookTimeoutSeconds = cast(uint) number(j, "webhookTimeoutSeconds", c.webhookTimeoutSeconds);
  if ("deliveryTenants" in j && j["deliveryTenants"].type == Json.Type.array) {
    c.deliveryTenants = null;
    foreach (t; j["deliveryTenants"])
      if (t.type == Json.Type.string)
        c.deliveryTenants ~= t.get!string;
  }
  validateConfig(c);
  return c;
}

void validateConfig(const EventsConfig c) {
  enforce(c.port > 0, "port must be > 0");
  enforce(["memory", "file"].canFind(c.storage), "storage must be 'memory' or 'file', not '" ~ c.storage ~ "'");
  enforce(c.defaultTenant.length > 0, "defaultTenant must not be empty");
  enforce(c.restPath != c.odataPath, "restPath and odataPath must differ");
  enforce(c.webhookTimeoutSeconds > 0, "webhookTimeoutSeconds must be > 0");
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
  o["odataPath"] = "odata/v4/em/";
  auto c = loadEventsConfig(o, "/nonexistent");
  assert(c.port == 9001 && c.storage == "memory" && c.odataPath == "/odata/v4/em");
  assert(c.toMaskedJson()["port"].get!long == 9001);
}
