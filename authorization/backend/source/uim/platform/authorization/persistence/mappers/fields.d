/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tolerant readers for stored JSON records (missing or mistyped fields fall back).
module uim.platform.authorization.persistence.mappers.fields;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

string textField(Json d, string key) {
  return key in d && d[key].type == Json.Type.string ? d[key].get!string : "";
}

bool boolField(Json d, string key, bool fallback = false) {
  return key in d && d[key].type == Json.Type.bool_ ? d[key].get!bool : fallback;
}

long longField(Json d, string key) {
  if (key !in d)
    return 0;
  auto v = d[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.float_)
    return cast(long) v.get!double;
  return 0;
}

string[] textsField(Json d, string key) @trusted {
  string[] values;
  if (key in d && d[key].type == Json.Type.array)
    foreach (v; d[key])
      if (v.type == Json.Type.string)
        values ~= v.get!string;
  return values;
}

/// Unknown or missing values fall back (records stay readable across versions).
E enumField(E)(Json d, string key, E fallback) {
  auto text = textField(d, key);
  if (text.length == 0)
    return fallback;
  try
    return parseDomainEnum!E(text);
  catch (AuthorizationException)
    return fallback;
}

Json textsJson(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
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
void readAudit(E)(ref E e, Json d) {
  alias TId = typeof(e.id);
  e.id = TId(textField(d, "id"));
  e.tenantId = TenantId(textField(d, "tenantId"));
  e.createdAt = longField(d, "createdAt");
  e.createdBy = UserId(textField(d, "createdBy"));
  e.updatedAt = longField(d, "updatedAt");
  e.updatedBy = UserId(textField(d, "updatedBy"));
}
