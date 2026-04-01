module domain.entities.permission;

import domain.types;

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
