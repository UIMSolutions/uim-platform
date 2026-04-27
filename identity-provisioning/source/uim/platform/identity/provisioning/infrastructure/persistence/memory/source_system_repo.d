/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.source_system;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.source_system;
import uim.platform.identity.provisioning.domain.ports.repositories.source_systems;

class MemorySourceSystemRepository : TenantRepository!(SourceSystem, SourceSystemId), SourceSystemRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!((e) => e.name == name);
  }
  SourceSystem findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return SourceSystem.init; // Return an empty SourceSystem if not found
  }


  size_t countByType(TenantId tenantId, SystemType systemType) {
    return findByType(tenantId, systemType).length;
  }
  SourceSystem[] filterByType(SourceSystem[] entries, SystemType systemType, uint offset = 0, uint limit = 0) {
    return (limit == 0)
        ? entries.filter!(e => e.systemType == systemType).skip(offset).array
        : entries.filter!(e => e.systemType == systemType).skip(offset).take(limit).array;
  }
  SourceSystem[] findByType(TenantId tenantId, SystemType systemType) {
    return filterByType(findByTenant(tenantId), systemType);
  }
  void removeByType(TenantId tenantId, SystemType systemType) {
    filterByType(findByTenant(tenantId), systemType).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, SystemStatus status) {
    return findByStatus(tenantId, status).length;
  }
  SourceSystem[] filterByStatus(SourceSystem[] entries, SystemStatus status, uint offset = 0, uint limit = 0) {
    return (limit == 0)
        ? entries.filter!(e => e.status == status).skip(offset).array
        : entries.filter!(e => e.status == status).skip(offset).take(limit).array;
  }
  SourceSystem[] findByStatus(TenantId tenantId, SystemStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, SystemStatus status) {
    filterByStatus(findByTenant(tenantId), status).each!(e => remove(e));
  }
  
}
