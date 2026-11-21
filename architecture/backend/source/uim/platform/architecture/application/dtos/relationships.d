/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Request models of the relationship use cases.
module uim.platform.architecture.application.dtos.relationships;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct CreateRelationshipRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional; generated if empty
  string type; /// ArchiMate relationship type, e.g. "serving"
  string sourceId;
  string targetId;
  string description;
}

struct UpdateRelationshipRequest {
  TenantId tenantId;
  UserId actor;
  RelationshipId id;
  Nullable!string description;
}

struct RelationshipFilter {
  string blockId; /// relationships with this block as source or target
  string type;
}
