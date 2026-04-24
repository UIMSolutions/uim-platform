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

class MemoryCleansingRuleRepository : TenantRepository!(CleansingRule, RuleId), CleansingRuleRepository {

  size_t countByDataset(TenantId tenantId, string datasetPattern) {
    return findByDataset(tenantId, datasetPattern).length;
  }

  CleansingRule[] filterByDataset(CleansingRule[] rules, string datasetPattern) {
    return rules.filter!(r => r.datasetPattern == datasetPattern).array;
  }

  CleansingRule[] findByDataset(TenantId tenantId, string datasetPattern) {
    return filterByDataset(findByTenant(tenantId), datasetPattern);
  }

  void removeByDataset(TenantId tenantId, string datasetPattern) {
    findByDataset(tenantId, datasetPattern).each!(entity => remove(entity.id));
  }

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }

  CleansingRule[] filterActive(CleansingRule[] rules, TenantId tenantId) {
    return rules.filter!(r => r.tenantId == tenantId && r.status == RuleStatus.active).array;
  }

  CleansingRule[] findActive(TenantId tenantId) {
    return filterActive(findByTenant(tenantId), tenantId);
  }

  void removeActive(TenantId tenantId) {
    findActive(tenantId).each!(entity => remove(entity.id));
  }

}
