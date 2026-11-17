/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.user_group;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A group of users that receives roles.
struct UserGroup {
  mixin TenantEntity!GroupId;

  string name; /// unique per tenant
  string description;
  GroupType groupType = GroupType.security;
  string[] memberIds; /// user ids
  string[] roles; /// role names
  bool active = true;
}
