/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.repositories.api_rules;

// import uim.platform.kyma.domain.entities.api_rule;
// import uim.platform.kyma.domain.ports.repositories.api_rules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryApiRuleRepository : TenantRepository!(ApiRule, ApiRuleId), ApiRuleRepository {



  bool existsByName(NamespaceId nsId, string name) {
    return findByNamespace(nsId).any!(e => e.name == name);
  }

  ApiRule findByName(NamespaceId nsId, string name) {
    foreach (e; findByNamespace(nsId))
      if (e.name == name)
        return e;
    return ApiRule.init;
  }

  ApiRule[] findByNamespace(NamespaceId nsId) {
    return findByTenant(tenantId).filter!(e => e.namespaceId == nsId).array;
  }

  ApiRule[] findByEnvironment(KymaEnvironmentId envId) {
    return findByTenant(tenantId).filter!(e => e.environmentId == envId).array;
  }

  ApiRule[] findByStatus(ApiRuleStatus status) {
    return findByTenant(tenantId).filter!(e => e.status == status).array;
  }

  void save(ApiRule rule) {
    store[rule.id] = rule;
  }

  void update(ApiRule rule) {
    if (existsById(rule.id))
      store[rule.id] = rule;
  }

  void remove(ApiRuleId ruleId) {
    if (existsById(ruleId))
      store.remove(ruleId);
  }
}
