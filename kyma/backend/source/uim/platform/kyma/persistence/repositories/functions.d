/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.functions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class FunctionRepository : KymaRepository!(ServerlessFunction, ServerlessFunctionId), IFunctionRepository {
  this() {
    super();
  }

  this(ITenantStore!(ServerlessFunction, ServerlessFunctionId) store) {
    super(store);
  }

  ServerlessFunction findByName(TenantId tenantId, NamespaceId namespaceId, string name) {
    return first(tenantId, (e) => e.namespaceId == namespaceId && e.name == name);
  }

  ServerlessFunction[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return where(tenantId, (e) => e.namespaceId == namespaceId);
  }

  ServerlessFunction[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return where(tenantId, (e) => e.environmentId == environmentId);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new FunctionRepository()));
}
