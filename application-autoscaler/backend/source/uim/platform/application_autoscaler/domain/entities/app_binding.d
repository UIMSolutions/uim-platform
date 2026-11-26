/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An application bound to the autoscaler (a Cloud Foundry app GUID or a
/// Kubernetes workload). The binding carries the attached policy and the
/// instance count the autoscaler last set.
module uim.platform.application_autoscaler.domain.entities.app_binding;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Upper bound of any instance count.
enum int maxInstancesLimit = 1000;

struct AppBinding {
  mixin TenantEntity!AppBindingId;

  string name; /// application name
  string appGuid; /// CF application GUID or workload reference (unique per tenant)
  string serviceInstanceId; /// autoscaler service instance the app is bound to
  string description;
  ScalingPolicyId policyId; /// attached policy ("" = none)
  BindingStatus status = BindingStatus.active;
  int currentInstances = 1;
  long lastScaledAt; /// std time of the last successful scaling (cool-down)
  long lastEvaluatedAt; /// std time of the last evaluation
  string lastDecision; /// short text of the last evaluation

  bool hasPolicy() const {
    return !policyId.isNull;
  }

  bool isAutoscaled() const {
    return status == BindingStatus.active && hasPolicy;
  }

  void validate() const {
    requireId(id.value, "Binding ID");
    requireText(name, "Application name");
    requireMaxLength(name, 200, "Application name");
    requireText(appGuid, "Application GUID");
    requireMaxLength(appGuid, 200, "Application GUID");
    requireMaxLength(serviceInstanceId, 200, "Service instance");
    requireMaxLength(description, 2000, "Description");
    requireRange(currentInstances, 0, maxInstancesLimit, "Current instances");
  }
}

///
unittest {
  AppBinding b;
  b.id = AppBindingId("b1");
  b.name = "shop";
  b.appGuid = "6f1c-4a";
  b.validate();
  assert(!b.isAutoscaled);
  b.policyId = ScalingPolicyId("p1");
  assert(b.isAutoscaled);
  b.status = BindingStatus.suspended;
  assert(!b.isAutoscaled);
  b.currentInstances = -1;
  assert(failsWith(AasErrorKind.invalid, () { b.validate(); }));
}
