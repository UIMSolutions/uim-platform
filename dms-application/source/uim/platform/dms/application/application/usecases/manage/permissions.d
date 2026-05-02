/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.permissions;

// // import std.datetime.systime : Clock;
// // import std.uuid : randomUUID;
// 
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.ports.repositories.permissions;
// import uim.platform.dms.application.domain.services.access_control_service;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManagePermissionsUseCase { // TODO: UIMUseCase {
  private IPermissionRepository permissions;
  private AccessControlService accessService;

  this(IPermissionRepository permissions, AccessControlService accessService) {
    this.permissions = permissions;
    this.accessService = accessService;
  }

  CommandResult grantPermission(CreatePermissionRequest r) {
    if (r.resourceId.isEmpty)
      return CommandResult(false, "", "Resource ID is required");
    if (r.userId.isEmpty)
      return CommandResult(false, "", "User ID is required");

    // Check if permission already exists for this user+resource
    if (!permissions.existsByResourceAndUser(r.tenantId, r.resourceId,
      r.resourceType, r.userId)) {
      auto existing = permissions.findByResourceAndUser(r.tenantId, r.resourceId,
        r.resourceType, r.userId);
      // Update existing
      existing.level = r.level;
      permissions.update(existing);
      return CommandResult(existing.id, "");
    }

    auto entity = new Permission();
    entity.id = randomUUID();
    entity.tenantId = r.tenantId;
    entity.resourceId = r.resourceId;
    entity.resourceType = r.resourceType;
    entity.userId = r.userId;
    entity.level = r.level;
    entity.createdBy = r.createdBy;
    entity.createdAt = Clock.currStdTime();

    permissions.save(entity);
    return CommandResult(entity.id, "");
  }

  Permission[] listByResource(TenantId tenantId, string resourceId, ResourceType resourceType) {
    return permissions.findByResource(tenantId, resourceId, resourceType);
  }

  Permission[] listByUser(TenantId tenantId, UserId userId) {
    return permissions.findByUser(tenantId, userId);
  }

  bool checkAccess(TenantId tenantId, string resourceId, ResourceType resourceType, UserId userId,
    PermissionLevel required) {
    return accessService.hasPermission(tenantId, resourceId, resourceType, userId, required);
  }

  CommandResult updatePermission(UpdatePermissionRequest r) {
    if (!permissions.existsById(r.tenantId, r.id))
      return CommandResult(false, "", "Permission not found");

    auto entity = permissions.findById(r.tenantId, r.id);
    entity.level = r.level;
    permissions.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult revokePermission(TenantId tenantId, PermissionId id) {
    if (!permissions.existsById(tenantId, id))
      return CommandResult(false, "", "Permission not found");

    permissions.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
