module domain.entities.share;

import domain.types;

class Share
{
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
