/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.target_systems;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.target_system;

interface TargetSystemRepository
{
  TargetSystem[] findByTenant(TenantId tenantId);
  TargetSystem* findById(TargetSystemId id, TenantId tenantId);
  TargetSystem* findByName(TenantId tenantId, string name);
  TargetSystem[] findByType(TenantId tenantId, SystemType systemType);
  TargetSystem[] findByStatus(TenantId tenantId, SystemStatus status);
  void save(TargetSystem entity);
  void update(TargetSystem entity);
  void remove(TargetSystemId id, TenantId tenantId);
}
