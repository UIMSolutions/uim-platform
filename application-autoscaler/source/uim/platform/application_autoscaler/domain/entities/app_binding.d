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
struct AppBindingEntity {
  AppBindingId id;
  TenantId     tenantId;
  string       appGuid;     // CF app GUID or K8s workload ref
  string       appName;
  string       serviceInstanceId;
  PolicyId     policyId;    // active policy (empty = no policy)
  int          currentInstances;
  long         boundAt;
  long         updatedAt;

  Json toJson() const @safe {
    auto j = Json.emptyObject;
    j["id"]                  = Json(id);
    j["tenant_id"]           = Json(tenantId);
    j["app_guid"]            = Json(appGuid);
    j["app_name"]            = Json(appName);
    j["service_instance_id"] = Json(serviceInstanceId);
    j["policy_id"]           = Json(policyId);
    j["current_instances"]   = Json(currentInstances);
    j["bound_at"]            = Json(boundAt);
    j["updated_at"]          = Json(updatedAt);
    return j;
  }
}
