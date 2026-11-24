/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → commands.
module uim.platform.data_retention.presentation.odata.payloads;

import std.traits : FieldNameTuple;
import uim.platform.data_retention;

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

/// API names of input members that are D keywords ("scope" → "scope_").
private Json withMemberNames(Json p) @trusted {
  if (!has(p, "scope"))
    return p;
  auto c = p.clone;
  c["scope_"] = c["scope"];
  c.remove("scope");
  return c;
}

/// The members of T present in the payload (PATCH semantics).
Changes!T changesOf(T)(Json payload) @trusted {
  auto p = withMemberNames(payload);
  Changes!T c;
  static foreach (name; FieldNameTuple!T) {
    if (has(p, name)) {
      {
        alias M = typeof(__traits(getMember, c.values, name));
        static if (is(M == string))
          __traits(getMember, c.values, name) = textOf(p, name);
        else static if (is(M == string[]))
          __traits(getMember, c.values, name) = textsOf(p, name);
        else static if (is(M == bool))
          __traits(getMember, c.values, name) = boolOf(p, name);
        else static if (is(M == int))
          __traits(getMember, c.values, name) = cast(int) longOf(p, name);
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

CreateDeletionRequestCommand deletionRequestCommand(const RequestContext ctx, Json p) {
  CreateDeletionRequestCommand c;
  c.tenantId = tenantOf(ctx);
  c.actor = actorOf(ctx);
  c.id = textOf(p, "id");
  c.dataSubjectId = DataSubjectId(textOf(p, "dataSubjectId").strip);
  if (textOf(p, "action").length)
    c.action = textOf(p, "action");
  c.reason = textOf(p, "reason");
  return c;
}

CreateArchivingJobCommand archivingJobCommand(const RequestContext ctx, Json p) {
  CreateArchivingJobCommand c;
  c.tenantId = tenantOf(ctx);
  c.actor = actorOf(ctx);
  c.id = textOf(p, "id");
  c.applicationGroupId = ApplicationGroupId(textOf(p, "applicationGroupId").strip);
  if (textOf(p, "operation").length)
    c.operation = textOf(p, "operation");
  c.dryRun = boolOf(p, "dryRun");
  c.referenceBefore = parseIsoTime(textOf(p, "referenceBefore"), "referenceBefore");
  c.scheduledAt = parseIsoTime(textOf(p, "scheduledAt"), "scheduledAt");
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
    throw DataRetentionException.invalid("Parameter '" ~ name ~ "' is required");
  return id;
}

///
unittest {
  auto c = changesOf!ApplicationGroupInput(Json(["scope": Json("regional"), "applicationIds": Json("a, b\nc"),
      "active": Json(false)]));
  assert(c.has("scope_") && c.values.scope_ == "regional" && c.values.applicationIds == ["a", "b", "c"]);
  assert(c.has("active") && !c.values.active && !c.has("name"));
  auto r = changesOf!ResidenceRuleInput(Json(["duration": Json("6"), "periodUnit": Json("months")]));
  assert(r.values.duration == 6 && r.has("duration") && !r.has("active"));
}
