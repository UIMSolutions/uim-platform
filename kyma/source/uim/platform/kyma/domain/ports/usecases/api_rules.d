/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.api_rules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for API rule management.
interface IManageApiRulesUseCase {

  UsecaseResult createApiRule(CreateApiRuleRequest req);

  UsecaseResult updateApiRule(string id, UpdateApiRuleRequest req);

  UsecaseResult updateApiRule(ApiRuleId id, UpdateApiRuleRequest req);

  bool hasApiRule(string id);

  bool hasApiRule(ApiRuleId id);

  ApiRule getApiRule(string id);

  ApiRule getApiRule(ApiRuleId id);

  ApiRule[] listByNamespace(string nsId);

  ApiRule[] listByNamespace(NamespaceId nsId);

  ApiRule[] listByEnvironment(string envId);

  ApiRule[] listByEnvironment(KymaEnvironmentId envId);

  UsecaseResult deleteApiRule(string id);

  UsecaseResult deleteApiRule(ApiRuleId id);

}
