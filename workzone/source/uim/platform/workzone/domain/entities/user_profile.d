/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.user_profile;

import uim.platform.workzone.domain.types;

/// A user profile — workspace membership and user information.
struct UserProfile {
  UserProfileId id;
  UserId userId;
  TenantId tenantId;
  string displayName;
  string email;
  string firstName;
  string lastName;
  string avatarUrl;
  string jobTitle;
  string department;
  string phone;
  string timezone;
  string language;
  RoleId[] roleIds;
  GroupId[] groupIds;
  WorkspaceId[] workspaceIds;
  bool active = true;
  long lastLoginAt;
  long createdAt;
  long updatedAt;
}
