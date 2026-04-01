module application.usecases.manage_permissions;

import std.datetime.systime : Clock;
import std.uuid : randomUUID;

import application.dto;
import  uim.platform.dms_application.domain.entities.permission;
import  uim.platform.dms_application.domain.ports.permission_repository;
import  uim.platform.dms_application.domain.services.access_control_service;
import  uim.platform.dms_application.domain.types;

class ManagePermissionsUseCase
{
  private IPermissionRepository permRepo;
  private AccessControlService accessService;

  this(IPermissionRepository permRepo, AccessControlService accessService)
  {
    this.permRepo = permRepo;
    this.accessService = accessService;
  }

  CommandResult grantPermission(CreatePermissionRequest r)
  {
    if (r.resourceId.length == 0)
      return CommandResult("", "Resource ID is required");
    if (r.userId.length == 0)
      return CommandResult("", "User ID is required");

    // Check if permission already exists for this user+resource
    auto existing = permRepo.findByResourceAndUser(r.resourceId, r.resourceType, r.userId, r.tenantId);
    if (existing !is null)
    {
      // Update existing
      existing.level = r.level;
      permRepo.update(existing);
      return CommandResult(existing.id, "");
    }

    auto entity = new Permission();
    entity.id = randomUUID().toString();
    entity.tenantId = r.tenantId;
    entity.resourceId = r.resourceId;
    entity.resourceType = r.resourceType;
    entity.userId = r.userId;
    entity.level = r.level;
    entity.createdBy = r.createdBy;
    entity.createdAt = Clock.currStdTime();

    permRepo.save(entity);
    return CommandResult(entity.id, "");
  }

  Permission[] listByResource(string resourceId, ResourceType resourceType, TenantId tenantId)
  {
    return permRepo.findByResource(resourceId, resourceType, tenantId);
  }

  Permission[] listByUser(UserId userId, TenantId tenantId)
  {
    return permRepo.findByUser(userId, tenantId);
  }

  bool checkAccess(string resourceId, ResourceType resourceType,
    UserId userId, PermissionLevel required, TenantId tenantId)
  {
    return accessService.hasPermission(resourceId, resourceType, userId, required, tenantId);
  }

  CommandResult updatePermission(UpdatePermissionRequest r)
  {
    auto entity = permRepo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult("", "Permission not found");

    entity.level = r.level;
    permRepo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult revokePermission(PermissionId id, TenantId tenantId)
  {
    auto entity = permRepo.findById(id, tenantId);
    if (entity is null)
      return CommandResult("", "Permission not found");

    permRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
