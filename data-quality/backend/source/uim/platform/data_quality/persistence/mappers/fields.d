/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tolerant readers / writers for stored JSON records.
module uim.platform.data_quality.persistence.mappers.fields;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

string textField(Json d, string key) {
  return key in d && d[key].type == Json.Type.string ? d[key].get!string : "";
}

long longField(Json d, string key, long fallback = 0) {
  if (key !in d)
    return fallback;
  auto v = d[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.float_)
    return cast(long) v.get!double;
  return fallback;
}

double doubleField(Json d, string key, double fallback = 0) {
  if (key !in d)
    return fallback;
  auto v = d[key];
  if (v.type == Json.Type.float_)
    return v.get!double;
  if (v.type == Json.Type.int_)
    return cast(double) v.get!long;
  return fallback;
}

bool boolField(Json d, string key, bool fallback = false) {
  return key in d && d[key].type == Json.Type.bool_ ? d[key].get!bool : fallback;
}

Json textsRecord(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

string[] textsField(Json d, string key) @trusted {
  string[] values;
  if (key in d && d[key].type == Json.Type.array)
    foreach (v; d[key].get!(Json[]))
      if (v.type == Json.Type.string)
        values ~= v.get!string;
  return values;
}

Json[] objectsField(Json d, string key) @trusted {
  Json[] items;
  if (key in d && d[key].type == Json.Type.array)
    foreach (v; d[key].get!(Json[]))
      if (v.type == Json.Type.object)
        items ~= v;
  return items;
}

/// Fields as an array of {name, value} objects (keeps the order).
Json fieldsRecord(const FieldValue[] fields) {
  auto a = Json.emptyArray;
  foreach (f; fields)
    a ~= Json(["name": Json(f.name), "value": Json(f.value)]);
  return a;
}

FieldValue[] fieldsField(Json d, string key) {
  FieldValue[] fields;
  foreach (o; objectsField(d, key))
    fields ~= FieldValue(textField(o, "name"), textField(o, "value"));
  return fields;
}

Json scoresRecord(const QualityScores s) {
  auto j = Json.emptyObject;
  j["completeness"] = s.completeness;
  j["validity"] = s.validity;
  j["uniqueness"] = s.uniqueness;
  j["consistency"] = s.consistency;
  j["accuracy"] = s.accuracy;
  return j;
}

QualityScores scoresField(Json d, string key) {
  QualityScores s;
  if (key !in d || d[key].type != Json.Type.object)
    return s;
  auto o = d[key];
  s.completeness = doubleField(o, "completeness", 100);
  s.validity = doubleField(o, "validity", 100);
  s.uniqueness = doubleField(o, "uniqueness", 100);
  s.consistency = doubleField(o, "consistency", 100);
  s.accuracy = doubleField(o, "accuracy", 100);
  return s;
}

/// Write the TenantEntity audit fields.
Json auditRecord(E)(const E e) {
  auto d = Json.emptyObject;
  d["id"] = e.id.value;
  d["tenantId"] = e.tenantId.value;
  d["createdAt"] = e.createdAt;
  d["createdBy"] = e.createdBy.value;
  d["updatedAt"] = e.updatedAt;
  d["updatedBy"] = e.updatedBy.value;
  return d;
}

/// Read the TenantEntity audit fields.
void readAudit(E, TId)(ref E e, Json d) {
  e.id = TId(textField(d, "id"));
  e.tenantId = TenantId(textField(d, "tenantId"));
  e.createdAt = longField(d, "createdAt");
  e.createdBy = UserId(textField(d, "createdBy"));
  e.updatedAt = longField(d, "updatedAt");
  e.updatedBy = UserId(textField(d, "updatedBy"));
}
