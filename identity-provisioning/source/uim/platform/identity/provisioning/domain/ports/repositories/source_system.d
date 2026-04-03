/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.source_system_repository;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.source_system;

interface SourceSystemRepository
{
  SourceSystem[] findByTenant(TenantId tenantId);
  SourceSystem* findById(SourceSystemId id, TenantId tenantId);
  SourceSystem* findByName(TenantId tenantId, string name);
  SourceSystem[] findByType(TenantId tenantId, SystemType systemType);
  SourceSystem[] findByStatus(TenantId tenantId, SystemStatus status);
  void save(SourceSystem entity);
  void update(SourceSystem entity);
  void remove(SourceSystemId id, TenantId tenantId);
}
