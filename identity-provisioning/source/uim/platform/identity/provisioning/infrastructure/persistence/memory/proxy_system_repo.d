/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.proxy_system;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.proxy_system;
import uim.platform.identity.provisioning.domain.ports.repositories.proxy_systems;

class MemoryProxySystemRepository : TenantRepository!(ProxySystem, ProxySystemId), ProxySystemRepository {


  ProxySystem* findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return &e;
    return null;
  }

  ProxySystem[] findByTenant(TenantId tenantId) {
    ProxySystem[] result;
    foreach (e; findAll)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProxySystem[] findBySource(SourceSystemId sourcetenantId, id tenantId) {
    ProxySystem[] result;
    foreach (e; findAll)
      if (e.sourceSystemId == sourceId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProxySystem[] findByTarget(TargetSystemId targettenantId, id tenantId) {
    ProxySystem[] result;
    foreach (e; findAll)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }
}
