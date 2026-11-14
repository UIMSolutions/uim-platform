/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.namespaces;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class NamespaceRepository : KymaRepository!(KymaNamespace, NamespaceId), INamespaceRepository {
  this() {
    super();
  }

  this(ITenantStore!(KymaNamespace, NamespaceId) store) {
    super(store);
  }

  KymaNamespace findByName(TenantId tenantId, KymaEnvironmentId environmentId, string name) {
    return first(tenantId, (e) => e.environmentId == environmentId && e.name == name);
  }

  KymaNamespace[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return where(tenantId, (e) => e.environmentId == environmentId);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new NamespaceRepository()));
}
