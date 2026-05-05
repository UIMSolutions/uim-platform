/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.target_systems;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.target_system;

interface TargetSystemRepository : ITenantRepository!(TargetSystem, TargetSystemId) {

  bool existsByName(TenantId tenantId, string name);
  TargetSystem findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countByType(TenantId tenantId, SystemType systemType);
  TargetSystem[] findByType(TenantId tenantId, SystemType systemType, size_t offset = 0, size_t limit = 0);
  void removeByType(TenantId tenantId, SystemType systemType);

  size_t countByStatus(TenantId tenantId, SystemStatus status);
  TargetSystem[] findByStatus(TenantId tenantId, SystemStatus status, size_t offset = 0, size_t limit = 0);
  void removeByStatus(TenantId tenantId, SystemStatus status);

}
