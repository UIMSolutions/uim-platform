/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.cleansing_rules;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.cleansing_rule;

/// Port for persisting data cleansing rules.
interface CleansingRuleRepository {
  CleansingRule[] findAll();
  CleansingRule[] findByTenant(TenantId tenantId);
  CleansingRule findById(RuleId id);
  CleansingRule[] findByDataset(TenantId tenantId, string datasetPattern);
  CleansingRule[] findActive(TenantId tenantId);
  void save(CleansingRule rule);
  void update(CleansingRule rule);
  void remove(RuleId id, TenantId tenantId);
}
