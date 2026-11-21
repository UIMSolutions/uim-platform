/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity ↔ record mapping.
module uim.platform.architecture.persistence.mappers.entities;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

private string str(Json j, string key, string fallback = "") {
  return key in j && j[key].type == Json.Type.string ? j[key].get!string : fallback;
}

private long num(Json j, string key) {
  if (key !in j)
    return 0;
  if (j[key].type == Json.Type.int_)
    return j[key].get!long;
  if (j[key].type == Json.Type.float_)
    return cast(long) j[key].get!double;
  return 0;
}

private string[] strs(Json j, string key) @trusted {
  string[] values;
  if (key in j && j[key].type == Json.Type.array)
    foreach (v; j[key].get!(Json[]))
      if (v.type == Json.Type.string)
        values ~= v.get!string;
  return values;
}

private Json list(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

private void audit(E)(ref Json j, const E e) {
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = e.createdAt;
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = e.updatedAt;
  j["updatedBy"] = e.updatedBy.value;
  j["schema"] = recordSchemaVersion;
}

private void unaudit(E, TId)(ref E e, Json j) {
  e.id = TId(str(j, "id"));
  e.tenantId = TenantId(str(j, "tenantId"));
  e.createdAt = num(j, "createdAt");
  e.createdBy = UserId(str(j, "createdBy"));
  e.updatedAt = num(j, "updatedAt");
  e.updatedBy = UserId(str(j, "updatedBy"));
}

Json blockToRecord(BuildingBlock b) {
  auto j = Json.emptyObject;
  audit(j, b);
  j["kind"] = cast(string) b.kind;
  j["name"] = b.name;
  j["description"] = b.description;
  j["owner"] = b.owner;
  j["status"] = cast(string) b.status;
  j["versionLabel"] = b.versionLabel;
  j["tags"] = list(b.tags);
  j["elementType"] = b.elementType;
  j["viewpoint"] = b.viewpoint;
  j["capability"] = b.capability;
  j["interfaces"] = list(b.interfaces);
  j["realizesId"] = b.realizesId.value;
  j["vendor"] = b.vendor;
  j["endpoint"] = b.endpoint;
  j["dataClassification"] = b.dataClassification;
  j["dataOwner"] = b.dataOwner;
  j["sourceSystem"] = b.sourceSystem;
  j["factSheetType"] = b.factSheetType;
  j["factSheetId"] = b.factSheetId;
  j["validUntil"] = b.validUntil;
  return j;
}

BuildingBlock recordToBlock(Json j) {
  BuildingBlock b;
  unaudit!(BuildingBlock, BuildingBlockId)(b, j);
  b.kind = parseBlockKind(str(j, "kind", "architecture"));
  b.name = str(j, "name");
  b.description = str(j, "description");
  b.owner = str(j, "owner");
  b.status = parseLifecycleStatus(str(j, "status", "proposed"));
  b.versionLabel = str(j, "versionLabel", "1.0.0");
  b.tags = strs(j, "tags");
  b.elementType = str(j, "elementType");
  b.viewpoint = str(j, "viewpoint");
  b.capability = str(j, "capability");
  b.interfaces = strs(j, "interfaces");
  b.realizesId = BuildingBlockId(str(j, "realizesId"));
  b.vendor = str(j, "vendor");
  b.endpoint = str(j, "endpoint");
  b.dataClassification = str(j, "dataClassification");
  b.dataOwner = str(j, "dataOwner");
  b.sourceSystem = str(j, "sourceSystem");
  b.factSheetType = str(j, "factSheetType");
  b.factSheetId = str(j, "factSheetId");
  b.validUntil = num(j, "validUntil");
  return b;
}

Json relationshipToRecord(Relationship r) {
  auto j = Json.emptyObject;
  audit(j, r);
  j["type"] = cast(string) r.type;
  j["sourceId"] = r.sourceId.value;
  j["targetId"] = r.targetId.value;
  j["description"] = r.description;
  return j;
}

Relationship recordToRelationship(Json j) {
  Relationship r;
  unaudit!(Relationship, RelationshipId)(r, j);
  r.type = parseRelationshipType(str(j, "type", "association"));
  r.sourceId = BuildingBlockId(str(j, "sourceId"));
  r.targetId = BuildingBlockId(str(j, "targetId"));
  r.description = str(j, "description");
  return r;
}

///
unittest {
  BuildingBlock b;
  b.id = BuildingBlockId("sbb-x");
  b.tenantId = TenantId("t");
  b.kind = BlockKind.solution;
  b.name = "X";
  b.status = LifecycleStatus.deprecated_;
  b.tags = ["a", "b"];
  b.realizesId = BuildingBlockId("abb-x");
  b.validUntil = 42;
  auto back = recordToBlock(blockToRecord(b));
  assert(back.id == b.id && back.kind == b.kind && back.status == b.status && back.tags == b.tags);
  assert(back.realizesId == b.realizesId && back.validUntil == 42 && back.tenantId.value == "t");

  Relationship r;
  r.id = RelationshipId("r");
  r.type = ArchiMateRelationshipType.flow;
  r.sourceId = BuildingBlockId("a");
  r.targetId = BuildingBlockId("b");
  auto rb = recordToRelationship(relationshipToRecord(r));
  assert(rb.type == r.type && rb.sourceId == r.sourceId && rb.targetId == r.targetId);
  // 1.x records ("identified", no kind) stay readable
  auto legacy = recordToBlock(parseJsonString(`{"id":"x","name":"Old","status":"identified"}`));
  assert(legacy.status == LifecycleStatus.proposed && legacy.kind == BlockKind.architecture);
}
