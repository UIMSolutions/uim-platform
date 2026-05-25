module uim.platform.private_link.domain.entities.service_instance;

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.entities.service_instance;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
/// Represents a private link service instance that establishes a private
/// connection between SAP BTP and an IaaS provider service resource.
struct ServiceInstance {
  mixin TenantEntity!(ServiceInstanceId);

  /// Human-readable name for this instance.
  string name;
  /// Optional description.
  string description;
  /// Unique identifier of the IaaS provider service resource (e.g. Azure resource ID).
  string resourceId;
  /// IaaS provider hosting the target resource.
  IaasProvider iaasProvider = IaasProvider.azure;
  /// Service plan tier.
  ServicePlan plan = ServicePlan.standard;
  /// Cloud region where the resource is located.
  string region;
  /// BTP subaccount ID that owns this instance.
  string subaccountId;
  /// Current provisioning/lifecycle status.
  InstanceStatus status = InstanceStatus.pending;
  /// Human-readable status message or error detail.
  string statusMessage;
  /// ID of the associated private endpoint (set after provisioning).
  PrivateEndpointId privateEndpointId;
  /// Unix timestamp (ms) of creation.
  long createdAt;
  /// Unix timestamp (ms) of last update.
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("name", name)
        .set("description", description)
        .set("resourceId", resourceId)
        .set("iaasProvider", iaasProvider.to!string)
        .set("plan", plan.to!string)
        .set("region", region)
        .set("subaccountId", subaccountId)
        .set("status", status.to!string)
        .set("statusMessage", statusMessage)
        .set("privateEndpointId", privateEndpointId.value)
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
