module infrastructure.persistence.memory.permission_repo;

import uim.platform.dms_application.domain.entities.permission;
import uim.platform.dms_application.domain.ports.permission_repository;
import uim.platform.dms_application.domain.types;

class InMemoryPermissionRepository : IPermissionRepository
{
  private Permission[string] store;

  Permission[] findByTenant(TenantId tenantId)
  {
    Permission[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  Permission findById(PermissionId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if ((*p).tenantId == tenantId)
        return *p;
    return null;
  }

  Permission[] findByResource(string resourceId, ResourceType resourceType, TenantId tenantId)
  {
    Permission[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.resourceId == resourceId && e.resourceType == resourceType)
        result ~= e;
    return result;
  }

  Permission[] findByUser(UserId userId, TenantId tenantId)
  {
    Permission[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.userId == userId)
        result ~= e;
    return result;
  }

  Permission findByResourceAndUser(string resourceId, ResourceType resourceType, UserId userId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.resourceId == resourceId
        && e.resourceType == resourceType && e.userId == userId)
        return e;
    return null;
  }

  void save(Permission perm) { store[perm.id] = perm; }
  void update(Permission perm) { store[perm.id] = perm; }
  void remove(PermissionId id, TenantId tenantId) { store.remove(id); }

  void removeByResource(string resourceId, ResourceType resourceType, TenantId tenantId)
  {
    string[] toRemove;
    foreach (k, ref e; store)
      if (e.tenantId == tenantId && e.resourceId == resourceId && e.resourceType == resourceType)
        toRemove ~= k;
    foreach (k; toRemove)
      store.remove(k);
  }
}
