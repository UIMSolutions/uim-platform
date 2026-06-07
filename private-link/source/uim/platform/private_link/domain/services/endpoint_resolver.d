/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.services.endpoint_resolver;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// Domain service: resolves hostname/IP for a service instance's private endpoint.
class EndpointResolver {
  private PrivateEndpointRepository endpoints;

  this(PrivateEndpointRepository endpoints) {
    this.endpoints = endpoints;
  }

  /// Returns the ready private endpoint for the given service instance, or PrivateEndpoint.init.
  PrivateEndpoint resolveForInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    auto candidates = endpoints.findByServiceInstance(tenantId, instanceId);
    foreach (ep; candidates) {
      if (ep.status == EndpointStatus.ready && ep.hostname.length > 0)
        return ep;
    }
    return PrivateEndpoint.init;
  }

  /// Returns true when at least one ready endpoint exists for the given instance.
  bool isReachable(TenantId tenantId, ServiceInstanceId instanceId) {
    auto ep = resolveForInstance(tenantId, instanceId);
    return ep.hostname.length > 0;
  }
}
