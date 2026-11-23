/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.data_quality.presentation.odata.payloads;

import std.traits : FieldNameTuple;
import uim.platform.data_quality;

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

double doubleOf(Json p, string key, double fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.float_)
    return v.get!double;
  if (v.type == Json.Type.int_)
    return cast(double) v.get!long;
  if (v.type == Json.Type.string) {
    double d;
    if (parseNumber(v.get!string, d))
      return d;
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

/// Record fields: ["name=value", …] or a "name=value" per line.
FieldValue[] fieldsOf(Json p, string key) @trusted {
  if (key !in p)
    return null;
  auto v = p[key];
  string[] lines;
  if (v.type == Json.Type.string)
    lines = v.get!string.split("\n");
  else if (v.type == Json.Type.array)
    foreach (item; v.get!(Json[]))
      if (item.type == Json.Type.string)
        lines ~= item.get!string;
  FieldValue[] fields;
  foreach (l; lines)
    if (l.strip.length)
      fields ~= parseFieldText(l);
  return fields;
}

/// The members of T present in the payload (PATCH semantics).
Changes!T changesOf(T)(Json p) @trusted {
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

/// A complete input: payload members over the defaults of T.
T inputOf(T)(Json p) {
  T input;
  changesOf!T(p).applyTo(input);
  return input;
}

/// Composite OData key → (dataset, id); throws notFound for malformed keys.
void splitKey(string key, out DatasetId ds, out string id, string what) {
  string d, i;
  if (!splitResourceKey(key, d, i))
    throw DataQualityException.notFound(what ~ " '" ~ key ~ "'");
  ds = DatasetId(d);
  id = i;
}

// ── requests ────────────────────────────────────────────────────────────────

CreateDatasetRequest createDatasetRequest(const RequestContext ctx, Json p) {
  CreateDatasetRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.category = textOf(p, "category");
  return r;
}

UpdateDatasetRequest updateDatasetRequest(const RequestContext ctx, string key, Json p) {
  UpdateDatasetRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = key;
  if (has(p, "name"))
    r.name = textOf(p, "name");
  if (has(p, "description"))
    r.description = textOf(p, "description");
  if (has(p, "category"))
    r.category = textOf(p, "category");
  return r;
}

CreateRecordRequest createRecordRequest(const RequestContext ctx, Json p) {
  CreateRecordRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.datasetId = DatasetId(textOf(p, "datasetId"));
  r.id = textOf(p, "id");
  r.fields = fieldsOf(p, "fields");
  return r;
}

UpdateRecordRequest updateRecordRequest(const RequestContext ctx, string key, Json p) {
  UpdateRecordRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  splitKey(key, r.datasetId, r.id, "Record");
  if (!has(p, "fields"))
    throw DataQualityException.invalid("Only the fields of a record can be changed");
  r.fields = fieldsOf(p, "fields");
  return r;
}

CreateValidationRuleRequest createValidationRuleRequest(const RequestContext ctx, Json p) {
  CreateValidationRuleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.rule = inputOf!ValidationRuleInput(p);
  return r;
}

UpdateValidationRuleRequest updateValidationRuleRequest(const RequestContext ctx, string key, Json p) {
  UpdateValidationRuleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = key;
  r.changes = changesOf!ValidationRuleInput(p);
  return r;
}

CreateCleansingRuleRequest createCleansingRuleRequest(const RequestContext ctx, Json p) {
  CreateCleansingRuleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.rule = inputOf!CleansingRuleInput(p);
  return r;
}

UpdateCleansingRuleRequest updateCleansingRuleRequest(const RequestContext ctx, string key, Json p) {
  UpdateCleansingRuleRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = key;
  r.changes = changesOf!CleansingRuleInput(p);
  return r;
}

CreateCleansingJobRequest createCleansingJobRequest(const RequestContext ctx, Json p) {
  CreateCleansingJobRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.datasetId = DatasetId(textOf(p, "datasetId"));
  r.ruleIds = textsOf(p, "ruleIds");
  r.dryRun = boolOf(p, "dryRun");
  r.revalidate = boolOf(p, "revalidate", true);
  return r;
}

CleanseAddressRequest cleanseAddressRequest(const RequestContext ctx, Json p, string prefix = "input") {
  string field(string name) {
    return prefix.length ? textOf(p, prefix ~ name) : textOf(p, name[0 .. 1].toLower ~ name[1 .. $]);
  }

  CleanseAddressRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.sourceRecordId = textOf(p, "sourceRecordId");
  r.input = AddressInput(field("Line1"), field("Line2"), field("City"), field("Region"), field("PostalCode"), field("Country"));
  return r;
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

DetectDuplicatesRequest detectRequest(const RequestContext ctx, Json p) {
  DetectDuplicatesRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.datasetId = DatasetId(textOf(p, "datasetId"));
  r.matchFields = textsOf(p, "matchFields");
  if (textOf(p, "strategy").length)
    r.strategy = textOf(p, "strategy");
  r.threshold = doubleOf(p, "threshold", r.threshold);
  return r;
}
