/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.namespace;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// A Kubernetes namespace within a Kyma environment.
struct Namespace {
  NamespaceId id;
  KymaEnvironmentId environmentId;
  TenantId tenantId;
  string name;
  string description;
  NamespaceStatus status = NamespaceStatus.active;

  // Resource quotas
  string cpuLimit;
  string memoryLimit;
  string cpuRequest;
  string memoryRequest;
  int podLimit;
  QuotaEnforcement quotaEnforcement = QuotaEnforcement.enforce;

  // Labels and annotations
  string[string] labels;
  string[string] annotations;

  // Istio sidecar injection
  bool istioInjection = true;

  // Metadata
  string createdBy;
  long createdAt;
  long modifiedAt;

  Json toJson() {
    return Json.emptyObject
      .set("id", id.value)
      .set("environmentId", environmentId.value)
      .set("tenantId", tenantId.value)
      .set("name", name)
      .set("description", description)
      .set("status", status.to!string())
      .set("cpuLimit", cpuLimit)
      .set("memoryLimit", memoryLimit)
      .set("cpuRequest", cpuRequest)
      .set("memoryRequest", memoryRequest)
      .set("podLimit", podLimit)
      .set("quotaEnforcement", quotaEnforcement.to!string)
      .set("labels", labels)
      .set("annotations", annotations)
      .set("istioInjection", istioInjection)
      .set("createdBy", createdBy);
  } 
}
