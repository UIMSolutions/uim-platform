/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.business_user;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A business user of a system with its business role assignments.
struct BusinessUser {
  mixin TenantEntity!BusinessUserId;

  SystemInstanceId systemInstanceId;
  string systemName;
  string name; /// user name (logon alias), unique per system
  string firstName;
  string lastName;
  string email;
  UserStatus status = UserStatus.active;

  string[] roles; /// assigned role names (mirror of roleAssignments, editable)
  RoleAssignment[] roleAssignments;

  bool passwordChangeRequired = true;
  long lastLoginAt;
  int failedLoginAttempts;
  long lockedAt;
}
