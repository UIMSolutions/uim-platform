/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.api_rules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of API rules (namespace scoped).
interface IApiRuleRepository : ITenantRepository!(ApiRule, ApiRuleId) {
  ApiRule findByName(TenantId tenantId, NamespaceId namespaceId, string name);
  ApiRule[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  ApiRule[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
  /// The rule exposing `host` in an environment (hosts are unique per cluster).
  ApiRule findByHost(TenantId tenantId, KymaEnvironmentId environmentId, string host);
}
