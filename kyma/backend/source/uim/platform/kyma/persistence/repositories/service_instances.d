/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.service_instances;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class ServiceInstanceRepository : KymaRepository!(ServiceInstance, ServiceInstanceId), IServiceInstanceRepository {
  this() {
    super();
  }

  this(ITenantStore!(ServiceInstance, ServiceInstanceId) store) {
    super(store);
  }

  ServiceInstance findByName(TenantId tenantId, NamespaceId namespaceId, string name) {
    return first(tenantId, (e) => e.namespaceId == namespaceId && e.name == name);
  }

  ServiceInstance[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return where(tenantId, (e) => e.namespaceId == namespaceId);
  }

  ServiceInstance[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return where(tenantId, (e) => e.environmentId == environmentId);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new ServiceInstanceRepository()));
}
