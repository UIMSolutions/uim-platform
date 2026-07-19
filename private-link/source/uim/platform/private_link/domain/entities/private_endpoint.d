/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.entities.private_endpoint;
import uim.platform.private_link;
mixin(ShowModule!());

@safe:
/// A private endpoint that provides an internal IP address to an IaaS provider
/// service, enabling private connectivity without traversing the public internet.
struct PrivateEndpoint {
  mixin TenantEntity!(PrivateEndpointId);

  /// ID of the parent service instance.
  ServiceInstanceId serviceInstanceId;
  /// Human-readable name for this endpoint.
  string name;
  /// Private IP address assigned by the IaaS provider.
  string privateIpAddress;
  /// Fully-qualified domain name for the private endpoint.
  string hostname;
  /// TCP port on which the target service listens.
  ushort port;
  /// Current approval/connection status.
  EndpointStatus status = EndpointStatus.pendingAcceptance;
  /// Human-readable status detail or error message.
  string statusMessage;
  /// IaaS-side endpoint resource ID (e.g. Azure private endpoint resource ID).
  string providerEndpointId;
  /// IaaS provider.
  IaasProvider iaasProvider = IaasProvider.azure;
  /// Cloud region.
  string region;
  /// Unix timestamp (ms) when the IaaS provider approved the endpoint.
  long approvedAt;
  /// Unix timestamp (ms) of creation.
  long createdAt;
  /// Unix timestamp (ms) of last update.
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("serviceInstanceId", serviceInstanceId.value)
        .set("name", name)
        .set("privateIpAddress", privateIpAddress)
        .set("hostname", hostname)
        .set("port", Json(port))
        .set("status", status.to!string)
        .set("statusMessage", statusMessage)
        .set("providerEndpointId", providerEndpointId)
        .set("iaasProvider", iaasProvider.to!string)
        .set("region", region)
        .set("approvedAt", Json(approvedAt))
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
