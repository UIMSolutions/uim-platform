/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Defensive accessors for record fields (missing or mistyped fields fall back to defaults).
module uim.platform.auditlog.persistence.mappers.json_fields;

import uim.platform.auditlog;

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
  return defaultValue;
}

int fieldInt(Json record, string key, int defaultValue = 0) {
  return cast(int) fieldLong(record, key, defaultValue);
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

Json stringsToJson(const string[] values) {
  auto arr = Json.emptyArray;
  foreach (v; values)
    arr ~= Json(v);
  return arr;
}

/// Parse an enum from its member name, falling back to a default.
E fieldEnum(E)(Json record, string key, E defaultValue) {
  auto name = fieldString(record, key);
  foreach (m; EnumMembers!E)
    if (m.to!string == name)
      return m;
  return defaultValue;
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

Json attributesToJson(const AuditAttribute[] attributes) {
  auto arr = Json.emptyArray;
  foreach (a; attributes) {
    auto j = Json.emptyObject;
    j["name"] = a.name;
    j["oldValue"] = a.oldValue;
    j["newValue"] = a.newValue;
    arr ~= j;
  }
  return arr;
}

AuditAttribute[] attributesFromJson(Json record, string key) {
  auto v = key in record;
  if (v is null || v.type != Json.Type.array)
    return null;
  AuditAttribute[] result;
  foreach (item; v.get!(Json[]))
    if (item.type == Json.Type.object)
      result ~= AuditAttribute(fieldString(item, "name"), fieldString(item, "oldValue"), fieldString(item, "newValue"));
  return result;
}

Json categoriesToJson(const AuditCategory[] categories) {
  auto arr = Json.emptyArray;
  foreach (c; categories)
    arr ~= Json(c.to!string);
  return arr;
}

AuditCategory[] categoriesFromJson(Json record, string key) {
  return fieldStrings(record, key).map!(s => s.toAuditCategory).array;
}
