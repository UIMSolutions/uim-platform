/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → commands.
module uim.platform.application_events.presentation.odata.payloads;

import std.traits : FieldNameTuple;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

TenantId tenantOf(const RequestContext ctx) {
  return TenantId(ctx.tenantId);
}

UserId actorOf(const RequestContext ctx) {
  return UserId(ctx.actor);
}

string textOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.string ? p[key].get!string : "";
}

bool has(Json p, string key) {
  return (key in p) !is null;
}

bool boolOf(Json p, string key, bool fallback = false) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.bool_)
    return v.get!bool;
  if (v.type == Json.Type.string)
    return ["true", "yes", "1", "x"].canFind(v.get!string.strip.toLower);
  return fallback;
}

long longOf(Json p, string key, long fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.float_)
    return cast(long) v.get!double;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.strip.to!long;
    catch (Exception) {
    }
  }
  return fallback;
}

double doubleOf(Json p, string key, double fallback = 0) @trusted {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.float_)
    return v.get!double;
  if (v.type == Json.Type.int_)
    return cast(double) v.get!long;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.strip.to!double;
    catch (Exception) {
    }
  }
  return fallback;
}

/// Array of strings (a single string is split at commas and new lines).
string[] textsOf(Json p, string key) @trusted {
  if (key !in p)
    return null;
  auto v = p[key];
  if (v.type == Json.Type.string)
    return v.get!string.splitter!(c => c == ',' || c == '\n').map!(s => s.strip.idup).filter!(s => s.length > 0).array;
  string[] values;
  if (v.type == Json.Type.array)
    foreach (item; v.get!(Json[]))
      if (item.type == Json.Type.string && item.get!string.strip.length > 0)
        values ~= item.get!string.strip;
  return values;
}

/// The members of T present in the payload (PATCH semantics). Members
/// ending in "_" are sent under their API name ("version" → version_).
Changes!T changesOf(T)(Json p) @trusted {
  Changes!T c;
  static foreach (name; FieldNameTuple!T) {
    {
      enum api = apiName(name);
      if (has(p, api)) {
        alias M = typeof(__traits(getMember, c.values, name));
        static if (is(M == string))
          __traits(getMember, c.values, name) = textOf(p, api);
        else static if (is(M == string[]))
          __traits(getMember, c.values, name) = textsOf(p, api);
        else static if (is(M == bool))
          __traits(getMember, c.values, name) = boolOf(p, api);
        else static if (is(M == int))
          __traits(getMember, c.values, name) = cast(int) longOf(p, api);
        else static if (is(M == long))
          __traits(getMember, c.values, name) = longOf(p, api);
        else static if (is(M == double))
          __traits(getMember, c.values, name) = doubleOf(p, api);
        else
          static assert(false, "unsupported member type of " ~ T.stringof ~ "." ~ name);
        c.set(name);
      }
    }
  }
  return c;
}

CreateCommand!TInput createCommandOf(TInput)(const RequestContext ctx, Json p) {
  CreateCommand!TInput c;
  c.tenantId = tenantOf(ctx);
  c.actor = actorOf(ctx);
  c.id = textOf(p, "id");
  c.input = changesOf!TInput(p);
  return c;
}

UpdateCommand!TInput updateCommandOf(TInput)(const RequestContext ctx, string key, Json p) {
  UpdateCommand!TInput c;
  c.tenantId = tenantOf(ctx);
  c.actor = actorOf(ctx);
  c.id = key;
  c.changes = changesOf!TInput(p);
  return c;
}

CreateUserRequest createUserRequest(const RequestContext ctx, Json p) {
  CreateUserRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.displayName = textOf(p, "displayName");
  r.password = textOf(p, "password");
  r.scopes = textsOf(p, "scopes");
  r.locked = boolOf(p, "locked");
  return r;
}

UpdateUserRequest updateUserRequest(const RequestContext ctx, string key, Json p) {
  UpdateUserRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = key;
  if (has(p, "displayName"))
    r.displayName = textOf(p, "displayName");
  if (has(p, "password") && textOf(p, "password").length)
    r.password = textOf(p, "password");
  if (has(p, "scopes"))
    r.scopes = textsOf(p, "scopes");
  if (has(p, "locked"))
    r.locked = boolOf(p, "locked");
  return r;
}

/// A required id parameter of an action.
string idParam(Json p, string name = "id") {
  auto id = textOf(p, name).strip;
  if (id.length == 0)
    throw AehException.invalid("Parameter '" ~ name ~ "' is required");
  return id;
}

/// A publish request from the parameters of PublishEvent / PreviewRouting:
/// type, source, subject?, id?, time?, data? (JSON text; anything else is
/// sent as a JSON string).
PublishRequest publishRequestOf(const RequestContext ctx, Json p) @trusted {
  auto e = Json.emptyObject;
  e["specversion"] = cloudEventsSpecVersion;
  foreach (k; ["type", "source", "subject", "id", "time"])
    if (textOf(p, k).strip.length)
      e[k] = textOf(p, k).strip;
  auto data = textOf(p, "data").strip;
  if (data.length) {
    try
      e["data"] = parseJsonString(data);
    catch (Exception)
      e["data"] = data;
  }
  return PublishRequest(tenantOf(ctx), actorOf(ctx), e);
}

///
unittest {
  auto c = changesOf!SubscriptionInput(Json(["name": Json("x"), "maxRetries": Json("3")]));
  assert(c.has("name") && c.has("maxRetries") && c.values.maxRetries == 3 && !c.has("eventType"));
  auto f = changesOf!FilterInput(Json(["operator": Json("oneOf"), "active": Json(false)]));
  assert(f.has("operator_") && f.values.operator_ == "oneOf" && !f.values.active);
  auto t = changesOf!TopicInput(Json(["version": Json("2.0.0")]));
  assert(t.has("version_") && t.values.version_ == "2.0.0");
  RequestContext ctx;
  ctx.tenantId = "t";
  auto r = publishRequestOf(ctx, Json(["type": Json("a.b"), "source": Json("s4"), "data": Json(`{"x":1}`)]));
  assert(r.event["data"]["x"].get!long == 1 && r.tenantId.value == "t");
  r = publishRequestOf(ctx, Json(["type": Json("a.b"), "source": Json("s4"), "data": Json("plain")]));
  assert(r.event["data"].get!string == "plain");
}
