/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.risk_rule_repo;

// import uim.platform.identity_authentication.domain.entities.risk_rule;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.risk_rule;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for risk rule persistence.
class MemoryRiskRuleRepository : RiskRuleRepository {
  private RiskRule[string] store;

  bool existsById(string id) {
    return (id in store) ? true : false;
  }

  RiskRule findById(string id) {
    if (existsById(id))
      return store[id];
    return RiskRule.init;
  }

  RiskRule[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(r => r.tenantId == tenantId).array;
  }

  void save(RiskRule rule) {
    store[rule.id] = rule;
  }

  void update(RiskRule rule) {
    store[rule.id] = rule;
  }

  void remove(string id) {
    store.remove(id);
  }
}
