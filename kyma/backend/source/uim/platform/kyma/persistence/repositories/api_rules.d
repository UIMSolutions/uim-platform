/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.api_rules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class ApiRuleRepository : KymaRepository!(ApiRule, ApiRuleId), IApiRuleRepository {
  this() {
    super();
  }

  this(ITenantStore!(ApiRule, ApiRuleId) store) {
    super(store);
  }

  ApiRule findByName(TenantId tenantId, NamespaceId namespaceId, string name) {
    return first(tenantId, (e) => e.namespaceId == namespaceId && e.name == name);
  }

  ApiRule[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return where(tenantId, (e) => e.namespaceId == namespaceId);
  }

  ApiRule[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return where(tenantId, (e) => e.environmentId == environmentId);
  }

  ApiRule findByHost(TenantId tenantId, KymaEnvironmentId environmentId, string host) {
    return first(tenantId, (e) => e.environmentId == environmentId && e.host == host);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new ApiRuleRepository()));
}
