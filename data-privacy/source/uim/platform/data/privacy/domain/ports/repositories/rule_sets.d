/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.rule_sets;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.rule_set;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying rule sets.
interface RuleSetRepository : ITenantRepository!(RuleSet, RuleSetId) {

  size_t countByBusinessContext(TenantId tenantId, BusinessContextId contextId);
  RuleSet[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId);
  void removeByBusinessContext(TenantId tenantId, BusinessContextId contextId);

  size_t countByStatus(TenantId tenantId, RuleSetStatus status);
  RuleSet[] findByStatus(TenantId tenantId, RuleSetStatus status);
  void removeByStatus(TenantId tenantId, RuleSetStatus status);

}
