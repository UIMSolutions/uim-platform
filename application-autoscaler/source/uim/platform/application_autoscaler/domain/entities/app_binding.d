/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.app_binding;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Represents an application bound to the autoscaler service instance.
struct AppBinding {
  mixin TenantEntity!AppBindingId;

  string       appGuid;     // CF app GUID or K8s workload ref
  string       appName;
  string       serviceInstanceId;
  ScalingPolicyId     policyId;    // active policy (empty = no policy)
  int          currentInstances;
  long         boundAt;
  long         updatedAt;

  Json toJson() const @safe {
    return entityToJson
    .set("app_guid", appGuid)
    .set("app_name", appName)
    .set("service_instance_id", serviceInstanceId)
    .set("policy_id", policyId)
    .set("current_instances", currentInstances)
    .set("bound_at", boundAt)
    .set("updated_at", updatedAt);
  }
}
