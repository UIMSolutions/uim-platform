module uim.platform.dms_application.domain.services.access_control_service;

import uim.platform.dms_application.domain.entities.permission;
import uim.platform.dms_application.domain.ports.permission_repository;
import uim.platform.dms_application.domain.types;

/// Domain service for access control checks.
class AccessControlService {
  private IPermissionRepository permRepo;

  this(IPermissionRepository permRepo) {
    this.permRepo = permRepo;
  }

  /// Check if a user has at least the required permission level on a resource.
  bool hasPermission(string resourceId, ResourceType resourceType,
    UserId userId, PermissionLevel required, TenantId tenantId) {
    auto perm = permRepo.findByResourceAndUser(resourceId, resourceType, userId, tenantId);
    if (perm is null)
      return false;
    return permissionRank(perm.level) >= permissionRank(required);
  }

  /// Get effective permission level for a user on a resource.
  PermissionLevel getEffectivePermission(string resourceId, ResourceType resourceType,
    UserId userId, TenantId tenantId) {
    auto perm = permRepo.findByResourceAndUser(resourceId, resourceType, userId, tenantId);
    if (perm is null)
      return PermissionLevel.read; // default minimum
    return perm.level;
  }

  /// Get all permissions for a resource.
  Permission[] getResourcePermissions(string resourceId, ResourceType resourceType, TenantId tenantId) {
    return permRepo.findByResource(resourceId, resourceType, tenantId);
  }

  private static int permissionRank(PermissionLevel level) {
    final switch (level) {
    case PermissionLevel.read:
      return 1;
    case PermissionLevel.write:
      return 2;
    case PermissionLevel.admin:
      return 3;
    case PermissionLevel.owner:
      return 4;
    }
  }
}
