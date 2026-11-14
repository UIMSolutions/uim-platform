/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.service_bindings;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of service bindings (namespace scoped).
interface IServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {
  ServiceBinding findByName(TenantId tenantId, NamespaceId namespaceId, string name);
  ServiceBinding[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  ServiceBinding[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
}
