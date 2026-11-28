/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → commands.
module uim.platform.ai_launchpad.presentation.odata.payloads;

import std.traits : FieldNameTuple;
import uim.platform.ai_launchpad;

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

/// Array of strings (a single string is split at new lines only: column
/// definitions such as "NET:DECIMAL(15,2)" and transformations contain commas).
string[] textsOf(Json p, string key) @trusted {
  if (key !in p)
    return null;
  auto v = p[key];
  if (v.type == Json.Type.string)
    return v.get!string.splitter('\n').map!(s => s.strip.idup).filter!(s => s.length > 0).array;
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
  r.email = textOf(p, "email");
  r.password = textOf(p, "password");
  r.roles = listOf(p, "roles");
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
  if (has(p, "email"))
    r.email = textOf(p, "email");
  if (has(p, "password") && textOf(p, "password").length)
    r.password = textOf(p, "password");
  if (has(p, "roles"))
    r.roles = listOf(p, "roles");
  if (has(p, "locked"))
    r.locked = boolOf(p, "locked");
  return r;
}

/// Short lists (roles, scopes): an array, or a text split at new lines, commas and blanks.
string[] listOf(Json p, string key) @trusted {
  if (key in p && p[key].type == Json.Type.string)
    return p[key].get!string.splitter!(c => c == '\n' || c == ',' || c == ' ' || c == ';')
      .map!(s => s.strip.idup).filter!(s => s.length > 0).array;
  return textsOf(p, key);
}

/// A required id parameter of an action.
string idParam(Json p, string name = "id") {
  auto id = textOf(p, name).strip;
  if (id.length == 0)
    throw AilpException.invalid("Parameter '" ~ name ~ "' is required");
  return id;
}

/// Inputs of a prompt run: a JSON object (sent as text or object) → name → text.
string[string] inputsParam(Json p, string name = "inputs") @trusted {
  string[string] inputs;
  if (name !in p || p[name].type == Json.Type.null_)
    return inputs;
  Json j = p[name];
  if (j.type == Json.Type.string) {
    auto text = j.get!string.strip;
    if (text.length == 0)
      return inputs;
    try
      j = parseJsonString(text);
    catch (Exception e)
      throw AilpException.invalid("Parameter '" ~ name ~ "' is not valid JSON: " ~ e.msg);
  }
  if (j.type != Json.Type.object)
    throw AilpException.invalid("Parameter '" ~ name ~ "' must be a JSON object of input values");
  foreach (k, v; j.get!(Json[string]))
    inputs[k] = v.type == Json.Type.string ? v.get!string : v.toString;
  return inputs;
}

///
unittest {
  auto c = changesOf!DeploymentInput(Json(["maxReplicas": Json("3"), "ttlMinutes": Json(60)]));
  assert(c.has("maxReplicas") && c.values.maxReplicas == 3 && c.values.ttlMinutes == 60 && !c.has("minReplicas"));
  auto m = changesOf!ModelInput(Json(["version": Json("2"), "sizeMiB": Json(1.5)]));
  assert(m.has("version_") && m.values.version_ == "2" && m.values.sizeMiB == 1.5);
  auto cfg = changesOf!ConfigurationInput(Json(["parameters": Json("epochs=10\nlr=0.01")]));
  assert(cfg.values.parameters == ["epochs=10", "lr=0.01"]);
  assert(listOf(Json(["roles": Json("Viewer, Operator")]), "roles") == ["Viewer", "Operator"]);
  assert(inputsParam(Json(["inputs": Json(`{"ticket":"x","n":3}`)]))["n"] == "3");
  assert(inputsParam(Json.emptyObject).length == 0);
  assert(failsWith(AilpErrorKind.invalid, () { inputsParam(Json(["inputs": Json("[1]")])); }));
  assert(failsWith(AilpErrorKind.invalid, () { idParam(Json.emptyObject); }));
}
