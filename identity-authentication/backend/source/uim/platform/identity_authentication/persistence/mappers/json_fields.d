/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Defensive accessors for record fields (missing or mistyped fields fall back to defaults).
module uim.platform.identity_authentication.persistence.mappers.json_fields;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

string fieldString(Json record, string key, string defaultValue = "") {
  auto v = key in record;
  if (v is null || v.type != Json.Type.string)
    return defaultValue;
  return v.get!string;
}

long fieldLong(Json record, string key, long defaultValue = 0) {
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

bool fieldBool(Json record, string key, bool defaultValue = false) {
  auto v = key in record;
  if (v is null || v.type != Json.Type.bool_)
    return defaultValue;
  return v.get!bool;
}

string[] fieldStrings(Json record, string key) {
  auto v = key in record;
  if (v is null || v.type != Json.Type.array)
    return null;
  string[] result;
  foreach (item; v.get!(Json[]))
    if (item.type == Json.Type.string)
      result ~= item.get!string;
  return result;
}

/// Parse an enum from its external value, falling back to a default.
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

/// Array of strings → Json array.
Json stringsRecord(const string[] values) {
  auto arr = Json.emptyArray;
  foreach (v; values)
    arr ~= Json(v);
  return arr;
}

/// Array of ids → Json array of their values.
Json idsRecord(TId)(const TId[] ids) {
  auto arr = Json.emptyArray;
  foreach (id; ids)
    arr ~= Json(id.value);
  return arr;
}

/// Json array of strings → ids.
TId[] fieldIds(TId)(Json record, string key) {
  return fieldStrings(record, key).map!(s => TId(s)).array;
}

/// Json array of objects (missing / mistyped → empty).
Json[] fieldObjects(Json record, string key) {
  auto v = key in record;
  if (v is null || v.type != Json.Type.array)
    return null;
  Json[] result;
  foreach (item; v.get!(Json[]))
    if (item.type == Json.Type.object)
      result ~= item;
  return result;
}
