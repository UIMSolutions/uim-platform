/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.api_rules;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.api_rule;
// import uim.platform.kyma.domain.ports.repositories.api_rules;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryApiRuleRepository : ApiRuleRepository {
  private ApiRule[ApiRuleId] store;

  ApiRule findById(ApiRuleId id) {
    if (id in store)
      return store[id];
    return ApiRule.init;
  }

  ApiRule findByName(NamespaceId nsId, string name) {
    foreach (e; findByNamespace)
      if (e.namespaceId == nsId && e.name == name)
        return e;
    return ApiRule.init;
  }

  ApiRule[] findByNamespace(NamespaceId nsId) {
    return store.byValue().filter!(e => e.namespaceId == nsId).array;
  }

  ApiRule[] findByEnvironment(KymaEnvironmentId envId) {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  ApiRule[] findByStatus(ApiRuleStatus status) {
    return store.byValue().filter!(e => e.status == status).array;
  }

  void save(ApiRule rule) {
    store[rule.ruleId] = rule;
  }

  void update(ApiRule rule) {
    if (ruleId in store)
      store[rule.ruleId] = rule;
  }

  void remove(ApiRuleId ruleId) {
    if (ruleId in store)
      store.remove(ruleId);
  }
}
