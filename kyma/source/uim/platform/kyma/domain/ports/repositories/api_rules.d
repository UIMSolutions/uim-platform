/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.api_rules;
// import uim.platform.kyma.domain.entities.api_rule;

import uim.platform.kyma;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — API rule persistence.
interface ApiRuleRepository : ITenantRepository!(ApiRule, ApiRuleId) {

  bool existsByName(TenantId tenantId, NamespaceId nsId, string name);
  ApiRule findByName(TenantId tenantId, NamespaceId nsId, string name);
  void removeByName(TenantId tenantId, NamespaceId nsId, string name);

  size_t countByNamespace(TenantId tenantId, NamespaceId nsId);
  ApiRule[] findByNamespace(TenantId tenantId, NamespaceId nsId);
  void removeByNamespace(TenantId tenantId, NamespaceId nsId);

  size_t countByEnvironment(TenantId tenantId, KymaEnvironmentId envId);
  ApiRule[] findByEnvironment(TenantId tenantId, KymaEnvironmentId envId);
  void removeByEnvironment(TenantId tenantId, KymaEnvironmentId envId);

  size_t countByStatus(TenantId tenantId, ApiRuleStatus status);
  ApiRule[] findByStatus(TenantId tenantId, ApiRuleStatus status);
  void removeByStatus(TenantId tenantId, ApiRuleStatus status);
  
}
