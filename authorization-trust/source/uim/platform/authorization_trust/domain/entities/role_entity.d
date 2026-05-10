/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.role_entity;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

/// A role template that bundles one or more scopes into a named authorization unit.
/// Administrators assign roles to role collections; role collections are assigned to users.
struct RoleEntity {
  RoleId   id;
  string   name;             // unique role name, e.g. "Viewer"
  string   description;
  string[] scopeReferences;  // scope names or IDs included in this role
  string   appId;            // owning application
  long     createdAt;
  long     updatedAt;
}
