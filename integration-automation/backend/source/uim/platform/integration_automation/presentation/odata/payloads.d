/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → commands.
module uim.platform.integration_automation.presentation.odata.payloads;

import std.traits : FieldNameTuple;
import uim.platform.integration_automation;

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

/// The members of T present in the payload (PATCH semantics). Members
/// ending in "_" are sent under their API name ("version" → version_).
Changes!T changesOf(T)(Json p) @trusted {
  Changes!T c;
  static foreach (name; FieldNameTuple!T) {
    {
      enum api = recordKey(name);
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

CreateWorkflowCommand createWorkflowCommand(const RequestContext ctx, Json p) {
  CreateWorkflowCommand c;
  c.tenantId = tenantOf(ctx);
  c.actor = actorOf(ctx);
  c.id = textOf(p, "id");
  c.scenarioId = textOf(p, "scenarioId");
  c.name = textOf(p, "name");
  c.description = textOf(p, "description");
  c.sourceSystemId = textOf(p, "sourceSystemId");
  c.targetSystemId = textOf(p, "targetSystemId");
  c.start = boolOf(p, "start");
  return c;
}

UpdateWorkflowCommand updateWorkflowCommand(const RequestContext ctx, string key, Json p) {
  UpdateWorkflowCommand c;
  c.tenantId = tenantOf(ctx);
  c.actor = actorOf(ctx);
  c.id = key;
  if (has(p, "name"))
    c.name = textOf(p, "name");
  if (has(p, "description"))
    c.description = textOf(p, "description");
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
    throw IaException.invalid("Parameter '" ~ name ~ "' is required");
  return id;
}

///
unittest {
  auto c = changesOf!ScenarioInput(Json(["version": Json("2.0"), "prerequisites": Json("a, b\nc")]));
  assert(c.has("version_") && c.values.version_ == "2.0" && c.values.prerequisites == ["a", "b", "c"]);
  assert(!c.has("name"));
  auto d = changesOf!DestinationInput(Json(["scope": Json("API"), "enabled": Json(false)]));
  assert(d.has("scope_") && d.values.scope_ == "API" && d.has("enabled") && !d.values.enabled);
  auto t = changesOf!ScenarioTaskInput(Json(["sequenceNumber": Json("30"), "afterPrevious": Json(false)]));
  assert(t.values.sequenceNumber == 30 && t.has("afterPrevious") && !t.values.afterPrevious);
}
