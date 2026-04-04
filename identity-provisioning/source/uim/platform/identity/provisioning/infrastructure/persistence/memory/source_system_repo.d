/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.source_system_repo;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.source_system;
import uim.platform.identity.provisioning.domain.ports.repositories.source_systems;

class MemorySourceSystemRepository : SourceSystemRepository {
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
