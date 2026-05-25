/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.memory.service_bindings;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
class MemoryServiceBindingRepository
    : TenantRepository!(ServiceBinding, ServiceBindingId),
      ServiceBindingRepository {

  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByTenant(tenantId).filter!(b => b.serviceInstanceId.value == instanceId.value).array;
  }

  ServiceBinding[] findByApplication(TenantId tenantId, string applicationId) {
    return findByTenant(tenantId).filter!(b => b.applicationId == applicationId).array;
  }

  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(b => remove(b));
  }
}
