/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.architecture.presentation.odata.payloads;

import uim.platform.architecture;

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

/// The attribute values present in the payload (null clears a value).
BlockValues blockValuesOf(Json p) {
  BlockValues v;
  void text(ref Nullable!string field, string key) {
    if (has(p, key))
      field = textOf(p, key);
  }

  void texts(ref Nullable!(string[]) field, string key) {
    if (has(p, key))
      field = textsOf(p, key);
  }

  text(v.name, "name");
  text(v.description, "description");
  text(v.owner, "owner");
  text(v.status, "status");
  text(v.versionLabel, "versionLabel");
  texts(v.tags, "tags");
  text(v.elementType, "elementType");
  text(v.viewpoint, "viewpoint");
  text(v.capability, "capability");
  texts(v.interfaces, "interfaces");
  text(v.realizesId, "realizesId");
  text(v.vendor, "vendor");
  text(v.endpoint, "endpoint");
  text(v.dataClassification, "dataClassification");
  text(v.dataOwner, "dataOwner");
  text(v.sourceSystem, "sourceSystem");
  text(v.factSheetType, "factSheetType");
  text(v.factSheetId, "factSheetId");
  text(v.validUntil, "validUntil");
  return v;
}

CreateBlockRequest createBlockRequest(const RequestContext ctx, Json p) {
  CreateBlockRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.kind = textOf(p, "kind");
  r.values = blockValuesOf(p);
  return r;
}

UpdateBlockRequest updateBlockRequest(const RequestContext ctx, string id, Json p) {
  UpdateBlockRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = BuildingBlockId(id);
  r.values = blockValuesOf(p);
  return r;
}

CreateRelationshipRequest createRelationshipRequest(const RequestContext ctx, Json p) {
  CreateRelationshipRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.type = textOf(p, "type");
  r.sourceId = textOf(p, "sourceId");
  r.targetId = textOf(p, "targetId");
  r.description = textOf(p, "description");
  return r;
}

UpdateRelationshipRequest updateRelationshipRequest(const RequestContext ctx, string id, Json p) {
  UpdateRelationshipRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = RelationshipId(id);
  if (has(p, "description"))
    r.description = textOf(p, "description");
  return r;
}

///
unittest {
  auto p = parseJsonString(`{"name":" CRM ","tags":"a, b","validUntil":null}`);
  auto v = blockValuesOf(p);
  assert(v.name.get == " CRM " && v.tags.get == ["a", "b"] && v.validUntil.get == "" && v.owner.isNull);
}
