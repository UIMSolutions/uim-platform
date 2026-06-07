/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.ports.repositories.private_endpoints;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// Port: repository contract for PrivateEndpoint persistence.
interface PrivateEndpointRepository : ITenantRepository!(PrivateEndpoint, PrivateEndpointId) {
  PrivateEndpoint[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  PrivateEndpoint[] findByStatus(TenantId tenantId, EndpointStatus status);
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
}
