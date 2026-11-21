/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Tolerant readers / writers for stored JSON records.
module uim.platform.ai_core.persistence.mappers.fields;

import uim.platform.ai_core;

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

/// Array of objects of a field (empty if missing).
Json[] objectsField(Json d, string key) @trusted {
  Json[] items;
  if (key in d && d[key].type == Json.Type.array)
    foreach (v; d[key].get!(Json[]))
      if (v.type == Json.Type.object)
        items ~= v;
  return items;
}

Json labelsRecord(const Label[] labels) {
  auto a = Json.emptyArray;
  foreach (l; labels)
    a ~= Json(["key": Json(l.key), "value": Json(l.value)]);
  return a;
}

Label[] labelsField(Json d, string key) {
  Label[] labels;
  foreach (o; objectsField(d, key))
    labels ~= Label(textField(o, "key"), textField(o, "value"));
  return labels;
}

Json refsRecord(const ArtifactRef[] refs) {
  auto a = Json.emptyArray;
  foreach (r; refs)
    a ~= Json(["key": Json(r.key), "artifactId": Json(r.artifactId.value)]);
  return a;
}

ArtifactRef[] refsField(Json d, string key) {
  ArtifactRef[] refs;
  foreach (o; objectsField(d, key))
    refs ~= ArtifactRef(textField(o, "key"), ArtifactId(textField(o, "artifactId")));
  return refs;
}

Json slotsRecord(const ArtifactSlot[] slots) {
  auto a = Json.emptyArray;
  foreach (s; slots)
    a ~= Json(["key": Json(s.key), "kind": Json(cast(string) s.kind), "description": Json(s.description)]);
  return a;
}

ArtifactSlot[] slotsField(Json d, string key) {
  ArtifactSlot[] slots;
  foreach (o; objectsField(d, key))
    slots ~= ArtifactSlot(textField(o, "key"), domainEnumOr!ArtifactKind(textField(o, "kind"), ArtifactKind.other),
      textField(o, "description"));
  return slots;
}

Json parametersRecord(const ParameterDef[] parameters) {
  auto a = Json.emptyArray;
  foreach (p; parameters)
    a ~= Json([
      "key": Json(p.key), "type": Json(p.type), "default": Json(p.defaultValue), "description": Json(p.description)
    ]);
  return a;
}

ParameterDef[] parametersField(Json d, string key) {
  ParameterDef[] parameters;
  foreach (o; objectsField(d, key)) {
    auto type = textField(o, "type");
    parameters ~= ParameterDef(textField(o, "key"), type.length ? type : "string", textField(o, "default"),
      textField(o, "description"));
  }
  return parameters;
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
