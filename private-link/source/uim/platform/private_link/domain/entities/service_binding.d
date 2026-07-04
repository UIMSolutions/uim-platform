/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.entities.service_binding;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
/// Represents the binding of a private link service instance to an application.
/// After binding, the application can reach the IaaS service via the private
/// endpoint hostname and IP without any public internet exposure.
struct ServiceBinding {
  mixin TenantEntity!(ServiceBindingId);

  /// ID of the service instance being bound.
  ServiceInstanceId serviceInstanceId;
  /// Identifier of the application being bound (CF app GUID or similar).
  string applicationId;
  /// Hostname the application uses to reach the private endpoint.
  string hostname;
  /// Private IP address of the private endpoint.
  string privateIpAddress;
  /// Port of the private endpoint.
  ushort port;
  /// Current binding lifecycle status.
  BindingStatus status = BindingStatus.creating;
  /// Unix timestamp (ms) of creation.
  long createdAt;
  /// Unix timestamp (ms) of deletion (0 if still active).
  long deletedAt;

  Json toJson() const {
    return entityToJson
        .set("serviceInstanceId", serviceInstanceId.value)
        .set("applicationId", applicationId)
        .set("hostname", hostname)
        .set("privateIpAddress", privateIpAddress)
        .set("port", Json(port))
        .set("status", status.to!string)
        .set("createdAt", Json(createdAt))
        .set("deletedAt", Json(deletedAt));
  }
}
