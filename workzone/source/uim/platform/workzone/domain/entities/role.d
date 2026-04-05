/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.role;

import uim.platform.workzone.domain.types;

/// A role — defines access permissions for site content and workspaces.
struct Role {
  RoleId id;
  TenantId tenantId;
  string name;
  string description;
  string[] permissions; // e.g., "read:workspace", "admin:site"
  UserId[] assignedUserIds;
  GroupId[] assignedGroupIds;
  bool isDefault;
  long createdAt;
  long updatedAt;
}
