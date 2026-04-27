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

  bool existsByName(TenantId tenantId, string name) {
    return findByName(tenantId, name) !is null;
  }

  ProxySystem findByName(TenantId tenantId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.name == name)
        return e;
    return ProxySystem.init; // null object pattern
  }

  size_t countBySource(TenantId tenantId, SourceSystemId sourceId) {
    return findBySource(tenantId, sourceId).length;
  }

  ProxySystem[] filterBySource(ProxySystem[] systems, SourceSystemId sourceId) {
    return systems.filter!(s => s.sourceSystemId == sourceId).array;
  }

  ProxySystem[] findBySource(TenantId tenantId, SourceSystemId sourceId) {
    return filterBySource(findByTenant(tenantId), sourceId);
  }

  void removeBySource(TenantId tenantId, SourceSystemId sourceId) {
    findBySource(tenantId, sourceId).each!(e => remove(e));
  }

  size_t countByTarget(TenantId tenantId, TargetSystemId targetId) {
    return findByTarget(tenantId, targetId).length;
  }

  ProxySystem[] filterByTarget(ProxySystem[] systems, TargetSystemId targetId) {
    return systems.filter!(s => s.targetSystemId == targetId).array;
  }

  ProxySystem[] findByTarget(TenantId tenantId, TargetSystemId targetId) {
    return filterByTarget(findByTenant(tenantId), targetId);
  }

  void removeByTarget(TenantId tenantId, TargetSystemId targetId) {
    findByTarget(tenantId, targetId).each!(e => remove(e));
  }
}
