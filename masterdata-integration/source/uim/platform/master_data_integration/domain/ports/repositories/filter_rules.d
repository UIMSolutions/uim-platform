/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.ports.repositories.filter_rules;

import uim.platform.master_data_integration.domain.entities.filter_rule;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — filter rule persistence.
interface FilterRuleRepository : ITenantRepository!(FilterRule, FilterRuleId) {

  size_t countByCategory(TenantId tenantId, MasterDataCategory category);
  FilterRule[] findByCategory(TenantId tenantId, MasterDataCategory category);
  void removeByCategory(TenantId tenantId, MasterDataCategory category);

  size_t countActive(TenantId tenantId);
  FilterRule[] findActive(TenantId tenantId);
  void removeActive(TenantId tenantId);

}
