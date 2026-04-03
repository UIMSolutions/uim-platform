/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.permission;

import uim.platform.dms.application.domain.types;

class Permission
{
  PermissionId id;
  TenantId tenantId;
  string resourceId; // documentId or folderId
  ResourceType resourceType;
  UserId userId;
  PermissionLevel level = PermissionLevel.read;
  UserId createdBy;
  long createdAt;
}
