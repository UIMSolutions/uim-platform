module infrastructure.persistence.memory.source_system_repo;

import domain.types;
import domain.entities.source_system;
import domain.ports.source_system_repository;

class MemorySourceSystemRepository : SourceSystemRepository
{
  private SourceSystem[string] store;

  void save(SourceSystem entity)
  {
    store[entity.id] = entity;
  }

  void update(SourceSystem entity)
  {
    store[entity.id] = entity;
  }

  void remove(SourceSystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  SourceSystem* findById(SourceSystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  SourceSystem* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  SourceSystem[] findByTenant(TenantId tenantId)
  {
    SourceSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  SourceSystem[] findByType(TenantId tenantId, SystemType systemType)
  {
    SourceSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.systemType == systemType)
        result ~= e;
    return result;
  }

  SourceSystem[] findByStatus(TenantId tenantId, SystemStatus status)
  {
    SourceSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
