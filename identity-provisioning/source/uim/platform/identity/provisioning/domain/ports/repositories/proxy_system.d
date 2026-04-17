/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.proxy_systems;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.proxy_system;

interface ProxySystemRepository {
  bool existsById(ProxySystemId tenantId, id tenantId);
  ProxySystem findById(ProxySystemId tenantId, id tenantId);

  bool existsByName(TenantId tenantId, string name);
  ProxySystem findByName(TenantId tenantId, string name);

  ProxySystem[] findByTenant(TenantId tenantId);
  ProxySystem[] findBySource(SourceSystemId sourcetenantId, id tenantId);
  ProxySystem[] findByTarget(TargetSystemId targettenantId, id tenantId);
  void save(ProxySystem entity);
  void update(ProxySystem entity);
  void remove(ProxySystemId tenantId, id tenantId);
}
