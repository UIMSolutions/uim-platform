/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.role_collection;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

/// A business-level grouping of roles, assigned as a whole to users.
/// Mirrors the SAP BTP concept of Role Collections in XSUAA.
struct RoleCollectionEntity {
  RoleCollectionId id;
  string           name;            // unique name, e.g. "ApplicationAdmin"
  string           description;
  string[]         roleReferences;  // role IDs or names included in this collection
  long             createdAt;
  long             updatedAt;
}
