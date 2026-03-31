module domain.ports.permission_repository;

import domain.entities.permission;
import domain.types;

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
