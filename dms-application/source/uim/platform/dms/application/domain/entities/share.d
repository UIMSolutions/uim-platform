/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.entities.share;

import uim.platform.dms.application.domain.types;

class Share {
  ShareId id;
  TenantId tenantId;
  DocumentId documentId;
  ShareType shareType = ShareType.internal;
  string sharedWith; // userId, email, or empty for public
  PermissionLevel permissionLevel = PermissionLevel.read;
  ShareStatus status = ShareStatus.active;
  long expiresAt; // 0 = no expiry
  UserId createdBy;
  long createdAt;
}
