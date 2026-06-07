/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.role_collection;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:
/// A business-level grouping of roles, assigned as a whole to users.
/// Mirrors the SAP BTP concept of Role Collections in XSUAA.
struct RoleCollectionEntity {
  mixin TenantEntity!RoleCollectionId;
  string           name;            // unique name, e.g. "ApplicationAdmin"
  string           description;
  string[]         roleReferences;  // role IDs or names included in this collection
  
  Json toJson() const {
    auto rrArr = Json.emptyArray;
    foreach (r; roleReferences)
      rrArr ~= Json(r);

    return entityToJson
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("roleReferences", rrArr);
  }
}
