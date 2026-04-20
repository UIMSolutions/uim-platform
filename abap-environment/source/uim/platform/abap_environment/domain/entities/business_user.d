/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.business_user;

// import uim.platform.abap_environment.domain.types;
import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
/// Business role assignment carried by a user.
struct RoleAssignment {
  BusinessRoleId roleId;
  string roleName;
  long assignedAt;
}

/// Business user in the ABAP environment.
struct BusinessUser {
  mixin TenantEntity!(BusinessUserId);
  SystemInstanceId systemInstanceId;
  string username;
  string firstName;
  string lastName;
  string email;
  UserStatus status = UserStatus.active;

  /// Role assignments
  RoleAssignment[] roleAssignments;

  /// Authentication
  bool passwordChangeRequired;
  long lastLoginAt;
  int failedLoginAttempts;

  Json toJson() const {
    auto j = entityToJson
      .set("systemInstanceId", systemInstanceId)
      .set("username", username)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("email", email)
      .set("status", status.to!string)
      .set("passwordChangeRequired", passwordChangeRequired)
      .set("lastLoginAt", lastLoginAt)
      .set("failedLoginAttempts", failedLoginAttempts);

    if (roleAssignments.length > 0) {
      auto roles = roleAssignments.map!(r => Json.emptyObject
        .set("roleId", r.roleId)
        .set("roleName", r.roleName)
        .set("assignedAt", r.assignedAt))();
      j = j.set("roleAssignments", roles);
    }

    return j;
  }
}
