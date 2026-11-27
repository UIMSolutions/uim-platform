/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → commands.
module uim.platform.datasphere.presentation.odata.payloads;

import std.traits : FieldNameTuple;
import uim.platform.datasphere;

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
/// ending in "_" are sent under their API name ("continue" → continue_).
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
    throw DspException.invalid("Parameter '" ~ name ~ "' is required");
  return id;
}

/// A JSON object parameter sent as text (e.g. the row of CheckDataAccess).
Json jsonParam(Json p, string name) @trusted {
  auto text = textOf(p, name).strip;
  if (text.length == 0)
    throw DspException.invalid("Parameter '" ~ name ~ "' is required");
  Json j;
  try
    j = parseJsonString(text);
  catch (Exception e)
    throw DspException.invalid("Parameter '" ~ name ~ "' is not valid JSON: " ~ e.msg);
  if (j.type != Json.Type.object)
    throw DspException.invalid("Parameter '" ~ name ~ "' must be a JSON object");
  return j;
}

///
unittest {
  auto c = changesOf!TaskInput(Json(["name": Json("x"), "maxRetries": Json("3")]));
  assert(c.has("name") && c.has("maxRetries") && c.values.maxRetries == 3 && !c.has("taskType"));
  auto s = changesOf!SpaceInput(Json(["diskQuotaGiB": Json(20), "auditLogEnabled": Json(true)]));
  assert(s.has("diskQuotaGiB") && s.values.diskQuotaGiB == 20 && s.values.auditLogEnabled);
  auto r = changesOf!RemoteTableInput(Json(["columns": Json("A:DECIMAL(15,2)\nB:INTEGER")]));
  assert(r.values.columns == ["A:DECIMAL(15,2)", "B:INTEGER"]);
  assert(jsonParam(Json(["row": Json(`{"COUNTRY":"DE"}`)]), "row")["COUNTRY"].get!string == "DE");
  assert(failsWith(DspErrorKind.invalid, () { jsonParam(Json(["row": Json("[1]")]), "row"); }));
  assert(failsWith(DspErrorKind.invalid, () { idParam(Json.emptyObject); }));
}
