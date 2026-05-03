/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.user_profile;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A user profile — workspace membership and user information.
struct UserProfile {
  mixin TenantEntity!(UserProfileId);
  
  UserId userId;
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
  
  Json toJson() const {
    return entityToJson
      .set("userId", userId.value)
      .set("displayName", displayName)
      .set("email", email)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("avatarUrl", avatarUrl)
      .set("jobTitle", jobTitle)
      .set("department", department)
      .set("phone", phone)
      .set("timezone", timezone)
      .set("language", language)
      .set("roleIds", roleIds.map!(r => r.value).array)
      .set("groupIds", groupIds.map!(g => g.value).array)
      .set("workspaceIds", workspaceIds.map!(w => w.value).array)
      .set("active", active)
      .set("lastLoginAt", lastLoginAt);
  }
}
