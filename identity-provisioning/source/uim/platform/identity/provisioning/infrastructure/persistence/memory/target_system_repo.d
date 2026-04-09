/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.target_system;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.target_system;
import uim.platform.identity.provisioning.domain.ports.repositories.target_systems;

class MemoryTargetSystemRepository : TargetSystemRepository {
  private TargetSystem[string] store;

  void save(TargetSystem entity) {
    store[entity.id] = entity;
  }

  void update(TargetSystem entity) {
    store[entity.id] = entity;
  }

  void remove(TargetSystemId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  TargetSystem* findById(TargetSystemId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  TargetSystem* findByName(TenantId tenantId, string name) {
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  TargetSystem[] findByTenant(TenantId tenantId) {
    TargetSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  TargetSystem[] findByType(TenantId tenantId, SystemType systemType) {
    TargetSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.systemType == systemType)
        result ~= e;
    return result;
  }

  TargetSystem[] findByStatus(TenantId tenantId, SystemStatus status) {
    TargetSystem[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
