/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.group;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A user group — for role and content assignment.
struct WZGroup {
  mixin TenantEntity!(GroupId);

  string name;
  string description;
  GroupType groupType = GroupType.security;
  UserId[] memberIds;
  RoleId[] roleIds;
  bool active = true;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("groupType", groupType.toString())
      .set("memberIds", memberIds.map!(u => u.value).array)
      .set("roleIds", roleIds.map!(r => r.value).array)
      .set("active", active);
  }
}
