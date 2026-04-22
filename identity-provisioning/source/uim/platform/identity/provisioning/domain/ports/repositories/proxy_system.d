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

  size_t countBySource(SourceSystemId sourceSystemId, TenantId tenantId);
  ProxySystem[] findBySource(SourceSystemId sourceSystemId, TenantId tenantId, uint offset = 0, uint limit = 100);
  void removeBySource(SourceSystemId sourceSystemId, TenantId tenantId);

  size_t countByTarget(TargetSystemId targetSystemId, TenantId tenantId);
  ProxySystem[] findByTarget(TargetSystemId targetSystemId, TenantId tenantId, uint offset = 0, uint limit = 100);
  void removeByTarget(TargetSystemId targetSystemId, TenantId tenantId);
}
