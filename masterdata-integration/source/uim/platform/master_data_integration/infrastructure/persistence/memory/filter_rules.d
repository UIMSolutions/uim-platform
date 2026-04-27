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

  FilterRule[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  FilterRule[] findByCategory(TenantId tenantId, MasterDataCategory category) {
    return findAll()r!(e => e.tenantId == tenantId && e.category == category).array;
  }

  FilterRule[] findActive(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId && e.isActive).array;
  }

}
