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
class MemoryRuleSetRepository : RuleSetRepository {
  private RuleSet[] store;

  RuleSet[] findByTenant(TenantId tenantId) {
    RuleSet[] result;
    foreach (s; findAll)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  RuleSet* findById(RuleSetId tenantId, id tenantId) {
    foreach (s; findAll)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  RuleSet[] findByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    RuleSet[] result;
    foreach (s; findByTenant(tenantId))
      if (s.businessContextId == contextId)
        result ~= s;
    return result;
  }

  RuleSet[] findByStatus(TenantId tenantId, RuleSetStatus status) {
    RuleSet[] result;
    foreach (s; findByTenant(tenantId))
      if (s.status == status)
        result ~= s;
    return result;
  }

  void save(RuleSet entity) {
    store ~= entity;
  }

  void update(RuleSet entity) {
    foreach (s; findAll)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(RuleSetId tenantId, id tenantId) {
    RuleSet[] kept;
    foreach (s; findAll)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
