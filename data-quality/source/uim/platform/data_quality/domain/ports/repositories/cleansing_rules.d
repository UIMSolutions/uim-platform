/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.domain.ports.repositories.cleansing_rules;

// import uim.platform.data_quality.domain.entities.cleansing_rule;
import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
/// Port for persisting data cleansing rules.
interface CleansingRuleRepository : ITenantRepository!(CleansingRule, CleansingRuleId) {

  size_t countByDataset(TenantId tenantId, string datasetPattern);
  CleansingRule[] findByDataset(TenantId tenantId, string datasetPattern);
  void removeByDataset(TenantId tenantId, string datasetPattern);

  size_t countActive(TenantId tenantId);
  CleansingRule[] findActive(TenantId tenantId);
  void removeActive(TenantId tenantId);

}
