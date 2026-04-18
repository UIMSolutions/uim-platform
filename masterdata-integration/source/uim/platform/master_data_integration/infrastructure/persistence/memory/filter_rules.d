/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.filter_rule;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.filter_rule;
import uim.platform.master_data_integration.domain.ports.repositories.filter_rules;

// import std.algorithm : filter;
// import std.array : array;

class MemoryFilterRuleRepository : FilterRuleRepository {
  private FilterRule[FilterRuleId] store;

  FilterRule findById(FilterRuleId id) {
    if (auto p = id in store)
      return *p;
    return FilterRule.init;
  }

  FilterRule[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  FilterRule[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.category == category).array;
  }

  FilterRule[] findActive(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.isActive).array;
  }

  void save(FilterRule rule) {
    store[rule.id] = rule;
  }

  void update(FilterRule rule) {
    store[rule.id] = rule;
  }

  void remove(FilterRuleId id) {
    store.remove(id);
  }
}
