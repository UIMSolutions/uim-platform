/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A scaling policy: the instance limits of the bound applications, the
/// time zone of its schedules and whether it is evaluated. Its dynamic
/// rules and schedules are separate aggregates referencing the policy.
module uim.platform.application_autoscaler.domain.entities.scaling_policy;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct ScalingPolicy {
  mixin TenantEntity!ScalingPolicyId;

  string name;
  string description;
  int instanceMinCount = 1;
  int instanceMaxCount = 5;
  string timezone = "UTC"; /// IANA name, "UTC" or a fixed offset such as "+01:00"
  PolicyStatus status = PolicyStatus.active;
  MetricAllowFrom customMetricAllowFrom = MetricAllowFrom.sameApp;

  bool isActive() const {
    return status == PolicyStatus.active;
  }

  /// value limited to [instanceMinCount, instanceMaxCount]
  int limit(int value) const {
    return clamp(value, instanceMinCount, instanceMaxCount);
  }

  void validate() const {
    requireId(id.value, "Policy ID");
    requireText(name, "Name");
    requireMaxLength(name, 200, "Name");
    requireMaxLength(description, 2000, "Description");
    requireRange(instanceMinCount, 1, maxInstancesLimit, "Minimum instances");
    requireRange(instanceMaxCount, 1, maxInstancesLimit, "Maximum instances");
    if (instanceMaxCount < instanceMinCount)
      throw AasException.invalid(format("Maximum instances (%d) must not be below minimum instances (%d)",
          instanceMaxCount, instanceMinCount));
    if (!isValidTimeZone(timezone))
      throw AasException.invalid("Unknown time zone '" ~ timezone ~ "' (an IANA name such as Europe/Berlin, UTC or +01:00)");
  }
}

///
unittest {
  ScalingPolicy p;
  p.id = ScalingPolicyId("p");
  p.name = "web";
  p.validate();
  assert(p.limit(0) == 1 && p.limit(9) == 5 && p.limit(3) == 3 && p.isActive);
  p.instanceMaxCount = 0;
  assert(failsWith(AasErrorKind.invalid, () { p.validate(); }));
  p.instanceMaxCount = 5;
  p.timezone = "Mars/Olympus";
  assert(failsWith(AasErrorKind.invalid, () { p.validate(); }));
}
