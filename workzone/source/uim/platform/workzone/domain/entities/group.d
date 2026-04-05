/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.group;

import uim.platform.workzone.domain.types;

/// A user group — for role and content assignment.
struct Group {
  GroupId id;
  TenantId tenantId;
  string name;
  string description;
  GroupType groupType = GroupType.security;
  UserId[] memberIds;
  RoleId[] roleIds;
  bool active = true;
  long createdAt;
  long updatedAt;
}
