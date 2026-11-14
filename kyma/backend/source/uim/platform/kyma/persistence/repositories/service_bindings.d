/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.persistence.repositories.service_bindings;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

class ServiceBindingRepository : KymaRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {
  this() {
    super();
  }

  this(ITenantStore!(ServiceBinding, ServiceBindingId) store) {
    super(store);
  }

  ServiceBinding findByName(TenantId tenantId, NamespaceId namespaceId, string name) {
    return first(tenantId, (e) => e.namespaceId == namespaceId && e.name == name);
  }

  ServiceBinding[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return where(tenantId, (e) => e.namespaceId == namespaceId);
  }

  ServiceBinding[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId) {
    return where(tenantId, (e) => e.environmentId == environmentId);
  }

  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return where(tenantId, (e) => e.serviceInstanceId == instanceId);
  }
}

///
unittest {
  assert(tenantRepositoryTest(new ServiceBindingRepository()));
}
