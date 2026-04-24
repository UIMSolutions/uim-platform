/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.rule_sets;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.rule_set;
// import uim.platform.data.privacy.domain.ports.repositories.rule_sets;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryRuleSetRepository : TenantRepository!(RuleSet, RuleSetId), RuleSetRepository {

  // #region ByBusinessContext
  size_t countByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    return findByBusinessContext(tenantId, contextId).length;
  }

  RuleSet[] filterByBusinessContext(RuleSet[] ruleSets, BusinessContextId contextId) {
    return ruleSets.filter!(s => s.businessContextId == contextId).array;
  }

  RuleSet[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    return filterByBusinessContext(findByTenant(tenantId), contextId);
  }

  void removeByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    findByBusinessContext(tenantId, contextId).each!(entity => remove(entity.id));
  }
  // #region ByBusinessContext

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, RuleSetStatus status) {
    return findByStatus(tenantId, status).length;
  }

  RuleSet[] filterByStatus(RuleSet[] ruleSets, RuleSetStatus status) {
    return ruleSets.filter!(s => s.status == status).array;
  }

  RuleSet[] findByStatus(TenantId tenantId, RuleSetStatus status) {
    return findByTenant(tenantId).filter!(s => s.status == status).array;
  }

  void removeByStatus(TenantId tenantId, RuleSetStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity.id));
  }
  // #endregion ByStatus

}
