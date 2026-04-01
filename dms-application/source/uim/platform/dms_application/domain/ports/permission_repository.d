module  uim.platform.dms_application.domain.ports.permission_repository;

import uim.platform.dms_application.domain.entities.permission;
import uim.platform.dms_application.domain.types;

interface IPermissionRepository
{
  Permission[] findByTenant(TenantId tenantId);
  Permission findById(PermissionId id, TenantId tenantId);
  Permission[] findByResource(string resourceId, ResourceType resourceType, TenantId tenantId);
  Permission[] findByUser(UserId userId, TenantId tenantId);
  Permission findByResourceAndUser(string resourceId, ResourceType resourceType, UserId userId, TenantId tenantId);
  void save(Permission perm);
  void update(Permission perm);
  void remove(PermissionId id, TenantId tenantId);
  void removeByResource(string resourceId, ResourceType resourceType, TenantId tenantId);
}
