/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.api_rule_repo;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.api_rule;
import uim.platform.kyma.domain.ports.api_rule_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryApiRuleRepository : ApiRuleRepository
{
  private ApiRule[ApiRuleId] store;

  ApiRule findById(ApiRuleId id)
  {
    if (auto p = id in store)
      return *p;
    return ApiRule.init;
  }

  ApiRule findByName(NamespaceId nsId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.namespaceId == nsId && e.name == name)
        return e;
    return ApiRule.init;
  }

  ApiRule[] findByNamespace(NamespaceId nsId)
  {
    return store.byValue().filter!(e => e.namespaceId == nsId).array;
  }

  ApiRule[] findByEnvironment(KymaEnvironmentId envId)
  {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  ApiRule[] findByStatus(ApiRuleStatus status)
  {
    return store.byValue().filter!(e => e.status == status).array;
  }

  void save(ApiRule rule)
  {
    store[rule.id] = rule;
  }

  void update(ApiRule rule)
  {
    store[rule.id] = rule;
  }

  void remove(ApiRuleId id)
  {
    store.remove(id);
  }
}
