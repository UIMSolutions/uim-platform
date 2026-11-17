/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.user_profile;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Profile of a workzone user.
struct UserProfile {
  mixin TenantEntity!UserProfileId;

  UserId userId; /// unique per tenant
  string displayName;
  string email;
  string firstName;
  string lastName;
  string avatarUrl;
  string jobTitle;
  string department;
  string phone;
  string timezone = "UTC";
  string language = "en";
  string[] roles; /// role names
  string[] groups; /// group names
  bool active = true;
  long lastLoginAt;
}
