/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.memory.service_instances;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
class MemoryServiceInstanceRepository
    : TenantRepository!(ServiceInstance, ServiceInstanceId),
      ServiceInstanceRepository {

  bool existsByName(TenantId tenantId, string name) {
    return find(tenantId).any!(i => i.name == name);
  }

  ServiceInstance findByName(TenantId tenantId, string name) {
    foreach (i; find(tenantId)) {
      if (i.name == name)
        return i;
    }
    return ServiceInstance.init;
  }

  ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
    return find(tenantId).filter!(i => i.status == status).array;
  }

  ServiceInstance[] findByIaasProvider(TenantId tenantId, IaasProvider provider) {
    return find(tenantId).filter!(i => i.iaasProvider == provider).array;
  }
}
