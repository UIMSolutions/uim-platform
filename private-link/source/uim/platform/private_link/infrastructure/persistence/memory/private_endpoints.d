/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.memory.private_endpoints;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
class MemoryPrivateEndpointRepository
    : TenantRepository!(PrivateEndpoint, PrivateEndpointId),
      PrivateEndpointRepository {

  PrivateEndpoint[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return find(tenantId).filter!(e => e.serviceInstanceId.value == instanceId.value).array;
  }

  PrivateEndpoint[] findByStatus(TenantId tenantId, EndpointStatus status) {
    return find(tenantId).filter!(e => e.status == status).array;
  }

  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(e => remove(e));
  }
}
