/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.proxy_system_repository;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.proxy_system;

interface ProxySystemRepository
{
  ProxySystem[] findByTenant(TenantId tenantId);
  ProxySystem* findById(ProxySystemId id, TenantId tenantId);
  ProxySystem* findByName(TenantId tenantId, string name);
  ProxySystem[] findBySource(SourceSystemId sourceId, TenantId tenantId);
  ProxySystem[] findByTarget(TargetSystemId targetId, TenantId tenantId);
  void save(ProxySystem entity);
  void update(ProxySystem entity);
  void remove(ProxySystemId id, TenantId tenantId);
}
