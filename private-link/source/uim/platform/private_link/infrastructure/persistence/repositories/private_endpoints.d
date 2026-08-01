/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.repositories.private_endpoints;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
class PrivateEndpointRepository : TenantRepository!(PrivateEndpoint, PrivateEndpointId), IPrivateEndpointRepository {

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByServiceInstance(tenantId, instanceId).length;
  }

  PrivateEndpoint[] filterByServiceInstance(PrivateEndpoint[] endpoints, ServiceInstanceId instanceId) {
    return endpoints.filter!(e => e.serviceInstanceId.value == instanceId.value).array;
  }

  PrivateEndpoint[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return filterByServiceInstance(findByTenant(tenantId), instanceId);
  }

  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(e => remove(e));
  }

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, EndpointStatus status) {
    return findByStatus(tenantId, status).length;
  }
  
  PrivateEndpoint[] filterByStatus(PrivateEndpoint[] endpoints, EndpointStatus status) {
    return endpoints.filter!(e => e.status == status).array;
  }

  PrivateEndpoint[] findByStatus(TenantId tenantId, EndpointStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, EndpointStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
  // #endregion ByStatus


}
