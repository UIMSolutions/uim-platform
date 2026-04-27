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

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(e => e.name == name);
  }
  TargetSystem findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return TargetSystem.init;
  }

  size_t countByType(TenantId tenantId, SystemType systemType) {
    return findByType(tenantId, systemType).length;
  }
  TargetSystem[] filterByType(TargetSystem[] systems, SystemType systemType) {
    return systems.filter!(s => s.systemType == systemType).array;
  }
  TargetSystem[] findByType(TenantId tenantId, SystemType systemType) {
    return filterByType(findByTenant(tenantId), systemType);
  }
  
  void removeByType(TenantId tenantId, SystemType systemType) {
    findByType(tenantId, systemType).each!(e => remove(e));
  }
  size_t countByStatus(TenantId tenantId, SystemStatus status) {
    return findByStatus(tenantId, status).length;
  }
  TargetSystem[] filterByStatus(TargetSystem[] systems, SystemStatus status) {
    return systems.filter!(s => s.status == status).array;
  }
  TargetSystem[] findByStatus(TenantId tenantId, SystemStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, SystemStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
}
