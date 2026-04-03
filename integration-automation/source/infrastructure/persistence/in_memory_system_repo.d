module uim.platform.xyz.infrastructure.persistence.memory.system_repo;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.system_connection;
// import uim.platform.xyz.domain.ports.system_repository;
import uim.platform.xyz.domain.ports;

import std.algorithm : filter;
import std.array : array;

class MemorySystemRepository : SystemRepository
{
  private SystemConnection[SystemId] store;

  SystemConnection[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  SystemConnection* findById(SystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  SystemConnection[] findByType(TenantId tenantId, SystemType systemType)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.systemType == systemType)
      .array;
  }

  SystemConnection[] findByStatus(TenantId tenantId, ConnectionStatus status)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.status == status)
      .array;
  }

  void save(SystemConnection system)
  {
    store[system.id] = system;
  }

  void update(SystemConnection system)
  {
    store[system.id] = system;
  }

  void remove(SystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
