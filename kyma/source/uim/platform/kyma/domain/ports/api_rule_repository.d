/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.api_rule_repository;

import uim.platform.kyma.domain.entities.api_rule;
import uim.platform.kyma.domain.types;

/// Port: outgoing — API rule persistence.
interface ApiRuleRepository
{
  ApiRule findById(ApiRuleId id);
  ApiRule findByName(NamespaceId nsId, string name);
  ApiRule[] findByNamespace(NamespaceId nsId);
  ApiRule[] findByEnvironment(KymaEnvironmentId envId);
  ApiRule[] findByStatus(ApiRuleStatus status);
  void save(ApiRule rule);
  void update(ApiRule rule);
  void remove(ApiRuleId id);
}
