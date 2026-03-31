module infrastructure.persistence.in_memory_target_system_repo;

import domain.types;
import domain.entities.target_system;
import domain.ports.target_system_repository;

class InMemoryTargetSystemRepository : TargetSystemRepository
{
  private TargetSystem[string] store;

  void save(TargetSystem entity)
  {
    store[entity.id] = entity;
  }

  void update(TargetSystem entity)
  {
    store[entity.id] = entity;
  }

  void remove(TargetSystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  TargetSystem* findById(TargetSystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  TargetSystem* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  TargetSystem[] findByTenant(TenantId tenantId)
  {
    TargetSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  TargetSystem[] findByType(TenantId tenantId, SystemType systemType)
  {
    TargetSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.systemType == systemType)
        result ~= e;
    return result;
  }

  TargetSystem[] findByStatus(TenantId tenantId, SystemStatus status)
  {
    TargetSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
