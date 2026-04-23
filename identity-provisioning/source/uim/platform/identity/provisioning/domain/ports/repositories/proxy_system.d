/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.proxy_systems;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.proxy_system;

interface ProxySystemRepository : ITenantRepository!(ProxySystem, ProxySystemId) {

  bool existsByName(TenantId tenantId, string name);
  ProxySystem findByName(TenantId tenantId, string name);
  void removeByName(TenantId tenantId, string name);

  size_t countBySource(TenantId tenantId, SourceSystemId sourceSystemId);
  ProxySystem[] findBySource(TenantId tenantId, SourceSystemId sourceSystemId, uint offset = 0, uint limit = 100);
  void removeBySource(TenantId tenantId, SourceSystemId sourceSystemId);

  size_t countByTarget(TenantId tenantId, TargetSystemId targetSystemId);
  ProxySystem[] findByTarget(TenantId tenantId, TargetSystemId targetSystemId, uint offset = 0, uint limit = 100);
  void removeByTarget(TenantId tenantId, TargetSystemId targetSystemId);
}
