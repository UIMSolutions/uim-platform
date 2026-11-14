/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.service_instances;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of service instances (namespace scoped).
interface IServiceInstanceRepository : ITenantRepository!(ServiceInstance, ServiceInstanceId) {
  ServiceInstance findByName(TenantId tenantId, NamespaceId namespaceId, string name);
  ServiceInstance[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  ServiceInstance[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
}
