/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Defensive accessors for record fields (missing or mistyped fields fall back to defaults).
module uim.platform.management.persistence.mappers.json_fields;

import uim.platform.management;

mixin(ShowModule!());

@safe:

string fieldString(Json record, string key, string defaultValue = "") {
  if (record.type != Json.Type.object)
    return defaultValue;
  auto v = key in record;
  if (v is null || v.type != Json.Type.string)
    return defaultValue;
  return v.get!string;
}

long fieldLong(Json record, string key, long defaultValue = 0) {
  if (record.type != Json.Type.object)
    return defaultValue;
  auto v = key in record;
  if (v is null)
    return defaultValue;
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.float_)
    return cast(long) v.get!double;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.to!long;
    catch (Exception)
      return defaultValue;
  }
  return defaultValue;
}

int fieldInt(Json record, string key, int defaultValue = 0) {
  return cast(int) fieldLong(record, key, defaultValue);
}

bool fieldBool(Json record, string key, bool defaultValue = false) {
  if (record.type != Json.Type.object)
    return defaultValue;
  auto v = key in record;
  if (v is null)
    return defaultValue;
  if (v.type == Json.Type.bool_)
    return v.get!bool;
  if (v.type == Json.Type.string)
    return ["true", "1", "yes", "on"].canFind(v.get!string.toLower);
  return defaultValue;
}

string[] fieldStrings(Json record, string key) {
  if (record.type != Json.Type.object)
    return null;
  auto v = key in record;
  if (v is null)
    return null;
  if (v.type == Json.Type.string) // "a, b" is accepted as a list as well
    return v.get!string.split(",").map!(s => s.strip).filter!(s => s.length > 0).array;
  return listFromJson(*v);
}

string[string] fieldMap(Json record, string key) {
  if (record.type != Json.Type.object)
    return null;
  auto v = key in record;
  return v is null ? null : propertiesFromJson(*v);
}

/// Parse an enum from its (external) member name, falling back to a default.
E fieldEnum(E)(Json record, string key, E defaultValue) {
  return parseEnum!E(fieldString(record, key), defaultValue);
}

/// Write the TenantEntity base fields.
Json baseRecord(T)(const ref T entity) {
  auto r = Json.emptyObject;
  r["id"] = entity.id.value;
  r["tenantId"] = entity.tenantId.value;
  r["createdBy"] = entity.createdBy.value;
  r["createdAt"] = entity.createdAt;
  r["updatedBy"] = entity.updatedBy.value;
  r["updatedAt"] = entity.updatedAt;
  return r;
}

/// Read the TenantEntity base fields.
void readBase(T)(ref T entity, Json r) {
  alias TId = typeof(entity.id);
  entity.id = TId(fieldString(r, "id"));
  entity.tenantId = TenantId(fieldString(r, "tenantId"));
  entity.createdBy = UserId(fieldString(r, "createdBy"));
  entity.createdAt = fieldLong(r, "createdAt");
  entity.updatedBy = UserId(fieldString(r, "updatedBy"));
  entity.updatedAt = fieldLong(r, "updatedAt");
}

///
unittest {
  mixin(ShowTest!("json_fields"));

  auto r = parseJsonString(`{"s": "x", "n": 5, "b": "true", "l": "a, b", "m": {"k": "v"}, "e": "kyma"}`);
  assert(fieldString(r, "s") == "x" && fieldString(r, "missing", "d") == "d");
  assert(fieldInt(r, "n") == 5 && fieldBool(r, "b"));
  assert(fieldStrings(r, "l") == ["a", "b"]);
  assert(fieldMap(r, "m") == ["k": "v"]);
  assert(fieldEnum!EnvironmentType(r, "e", EnvironmentType.cloudFoundry) == EnvironmentType.kyma);
  assert(fieldString(Json(null), "s") == "");
}
