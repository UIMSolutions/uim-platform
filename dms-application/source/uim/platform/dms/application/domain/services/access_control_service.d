/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.services.access_control_service;

// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.ports.repositories.permissions;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
/// Domain service for access control checks.
class AccessControlService {
  private IPermissionRepository permissions;

  this(IPermissionRepository permissions) {
    this.permissions = permissions;
  }

  /// Check if a user has at least the required permission level on a resource.
  bool hasPermission(TenantId tenantId, string resourceId, ResourceType resourceType, UserId userId,
      PermissionLevel required) {
    auto perm = permissions.findByResourceAndUser(tenantId, resourceId, resourceType, userId);
    if (perm.isNull)
      return false;
    return permissionRank(perm.level) >= permissionRank(required);
  }

  /// Get effective permission level for a user on a resource.
  PermissionLevel getEffectivePermission(TenantId tenantId, string resourceId,
      ResourceType resourceType, UserId userId) {
    if (!permissions.existsByResourceAndUser(tenantId, resourceId, resourceType, userId))
      return PermissionLevel.read; // default minimum

    auto perm = permissions.findByResourceAndUser(tenantId, resourceId, resourceType, userId);
    return perm.level;
  }

  /// Get all permissions for a resource.
  Permission[] getResourcePermissions(TenantId tenantId, string resourceId, ResourceType resourceType) {
    return permissions.findByResource(tenantId, resourceId, resourceType);
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
