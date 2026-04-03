/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.proxy_system_repo;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.proxy_system;
import uim.platform.identity.provisioning.domain.ports.proxy_system_repository;

class MemoryProxySystemRepository : ProxySystemRepository
{
  private ProxySystem[string] store;

  void save(ProxySystem entity)
  {
    store[entity.id] = entity;
  }

  void update(ProxySystem entity)
  {
    store[entity.id] = entity;
  }

  void remove(ProxySystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  ProxySystem* findById(ProxySystemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ProxySystem* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  ProxySystem[] findByTenant(TenantId tenantId)
  {
    ProxySystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProxySystem[] findBySource(SourceSystemId sourceId, TenantId tenantId)
  {
    ProxySystem[] result;
    foreach (ref e; store)
      if (e.sourceSystemId == sourceId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProxySystem[] findByTarget(TargetSystemId targetId, TenantId tenantId)
  {
    ProxySystem[] result;
    foreach (ref e; store)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }
}
