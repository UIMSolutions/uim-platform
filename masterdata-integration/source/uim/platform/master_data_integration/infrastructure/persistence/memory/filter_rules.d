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

class MemoryFilterRuleRepository : TenantRepository!(FilterRule, FilterRuleId), FilterRuleRepository {

  size_t countByCategory(TenantId tenantId, MasterDataCategory category) {
    return findByCategory(tenantId, category).length;
  }

  FilterRule[] filterByCategory(FilterRule[] rules, MasterDataCategory category) {
    return rules.filter!(e => e.category == category).array;
  }

  FilterRule[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return filterByCategory(findByTenant(tenantId), category);
  }

  void removeByCategory(TenantId tenantId, MasterDataCategory category) {
    findByCategory(tenantId, category).each!(e => remove(e));
  }

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }

  FilterRule[] filterActive(FilterRule[] rules) {
    return rules.filter!(e => e.isActive).array;
  }

  FilterRule[] findActive(TenantId tenantId) {
    return filterActive(findByTenant(tenantId));
  }

  void removeActive(TenantId tenantId) {
    findActive(tenantId).each!(e => remove(e));
  }

}
