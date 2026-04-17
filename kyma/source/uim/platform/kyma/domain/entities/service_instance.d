/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.service_instance;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// A service instance provisioned from the BTP service catalog.
struct ServiceInstance {
  ServiceInstanceId id;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  ServiceInstanceStatus status = ServiceInstanceStatus.creating;

  // Service catalog reference
  string serviceOfferingName;
  string servicePlanName;
  string servicePlanId;
  string externalName;

  // Parameters
  string parametersJson;

  // Labels and annotations
  string[string] labels;

  // Binding count
  int bindingCount;

  // Metadata
  string createdBy;
  long createdAt;
  long modifiedAt;

  Json toJson() {
    return Json.emptyObject
      .set("id", id.value)
      .set("namespaceId", namespaceId.value)
      .set("environmentId", environmentId.value)
      .set("tenantId", tenantId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string())
      .set("serviceOfferingName", serviceOfferingName)
      .set("servicePlanName", servicePlanName)
      .set("servicePlanId", servicePlanId)
      .set("externalName", externalName)
      .set("parametersJson", parametersJson)
      .set("labels", labels)
      .set("bindingCount", bindingCount)
      .set("createdBy", createdBy)
      .set("createdAt", createdAt)
      .set("modifiedAt", modifiedAt);
  }
}
