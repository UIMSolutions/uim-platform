/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.entities.user_assignment;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:
/// Assignment of a role collection to a specific user (or user group).
/// Mirrors the SAP BTP user-role-collection assignment.
struct UserAssignment {
  mixin TenantEntity!UserAssignmentId;

  UserId           userId;           // subject identifier from IdP
  string           userEmail;        // human-readable email
  RoleCollectionId roleCollectionId; // assigned role collection
  string           origin;           // IdP alias from which the user originates
  
  Json toJson() const {
    return entityToJson
      .set("userId", userId)
      .set("userEmail", userEmail)
      .set("roleCollectionId", roleCollectionId)
      .set("origin", origin);
  }
}
