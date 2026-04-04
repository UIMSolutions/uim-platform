/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.access_rules;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.access_rule;
// import uim.platform.connectivity.domain.ports.repositories.access_rules;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryAccessRuleRepository : AccessRuleRepository {
  private AccessRule[RuleId] store;

  AccessRule findById(RuleId id)
  {
    if (auto p = id in store)
      return *p;
    return AccessRule.init;
  }

  AccessRule[] findByConnector(ConnectorId connectorId)
  {
    return store.byValue().filter!(e => e.connectorId == connectorId).array;
  }

  AccessRule[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(AccessRule entity)
  {
    store[entity.id] = entity;
  }

  void update(AccessRule entity)
  {
    store[entity.id] = entity;
  }

  void remove(RuleId id)
  {
    store.remove(id);
  }
}
