/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.cleansing_rules;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.cleansing_rule;
import uim.platform.data.quality.domain.ports.repositories.cleansing_rules;

// import std.algorithm : filter;
// import std.array : array;

class MemoryCleansingRuleRepository : CleansingRuleRepository {
  private CleansingRule[RuleId] store;

  CleansingRule[] findAll() {
    return store.byValue().array;
  }

  CleansingRule[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId).array;
  }

  CleansingRule* findById(RuleId id) {
    if (auto p = id in store)
      return p;
    return null;
  }

  CleansingRule[] findByDataset(TenantId tenantId, string datasetPattern) {
    return store.byValue().filter!(r => r.tenantId == tenantId
        && r.datasetPattern == datasetPattern).array;
  }

  CleansingRule[] findActive(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId && r.status == RuleStatus.active)
      .array;
  }

  void save(CleansingRule rule) {
    store[rule.id] = rule;
  }

  void update(CleansingRule rule) {
    store[rule.id] = rule;
  }

  void remove(RuleId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
