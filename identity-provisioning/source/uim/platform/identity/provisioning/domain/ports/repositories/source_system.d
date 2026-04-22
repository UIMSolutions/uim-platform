/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.source_systems;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.source_system;

interface SourceSystemRepository : ITenantRepository!(SourceSystem, SourceSystemId) {
  
  bool existsByName(TenantId tenantId, string name);
  SourceSystem findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);
  
  size_t countByType(TenantId tenantId, SystemType systemType);
  SourceSystem[] findByType(TenantId tenantId, SystemType systemType);
  void removeByType(TenantId tenantId, SystemType systemType);
  
  size_t countByStatus(TenantId tenantId, SystemStatus status);
  SourceSystem[] findByStatus(TenantId tenantId, SystemStatus status);
  void removeByStatus(TenantId tenantId, SystemStatus status);
  
}
