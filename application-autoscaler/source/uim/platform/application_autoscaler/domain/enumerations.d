/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.enumerations;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Metric types (standard)
// ---------------------------------------------------------------------------
enum MetricType {
  memoryused,
  memoryutil,
  cpu,
  cpuutil,
  disk,
  diskutil,
  throughput,
  responsetime,
  custom_,
}
MetricType toMetricType(string s) {
  const map = [
    "memoryused": MetricType.memoryused,
    "memoryutil": MetricType.memoryutil,
    "cpu": MetricType.cpu,
    "cpuutil": MetricType.cpuutil,
    "disk": MetricType.disk,
    "diskutil": MetricType.diskutil,
    "throughput": MetricType.throughput,
    "responsetime": MetricType.responsetime,
    "custom": MetricType.custom_
  ];
}

// ---------------------------------------------------------------------------
// Comparison operator for scaling rules
// ---------------------------------------------------------------------------
enum ScalingOperator {
  lt,
  gt,
  lte,
  gte,
}
ScalingOperator toScalingOperator(string s) {
  const map = [
    "<":  ScalingOperator.lt,
    ">":  ScalingOperator.gt,
    "<=": ScalingOperator.lte,
    ">=": ScalingOperator.gte,
    "lt": ScalingOperator.lt,
    "gt": ScalingOperator.gt,
    "lte": ScalingOperator.lte,
    "gte": ScalingOperator.gte
  ];
  return map.get(s, ScalingOperator.gte);
} 

// ---------------------------------------------------------------------------
// Scaling direction result
// ---------------------------------------------------------------------------
enum ScalingDirection {
  // Scale out (add instances)
  scaleOut,
  // Scale in (remove instances)
  scaleIn,
  // No scaling action
  none,
}
ScalingDirection toScalingDirection(string s) {
  const map = [
    "scale_out": ScalingDirection.scaleOut,
    "scale_in": ScalingDirection.scaleIn,
    "none": ScalingDirection.none
  ];
  return map.get(s.toLower, ScalingDirection.none)  ;
}

// ---------------------------------------------------------------------------
// Scaling event status
// ---------------------------------------------------------------------------
enum ScalingStatus {
  // Scaling action succeeded
  succeeded,
  // Scaling action failed
  failed,
  // Scaling action was ignored due to cooldown or other constraints
  ignored,
}
ScalingStatus toScalingStatus(string s) {
  const map = [
    "succeeded": ScalingStatus.succeeded,
    "failed":    ScalingStatus.failed,
    "ignored":   ScalingStatus.ignored
  ];
  return map.get(s.toLower, ScalingStatus.ignored);
}

// ---------------------------------------------------------------------------
// Policy status
// ---------------------------------------------------------------------------
enum PolicyStatus {
  // Active and being evaluated
  active,
  // Inactive and not being evaluated
  inactive,
  // Deleted but not yet removed from the system
  deleted_,
}
PolicyStatus toPolicyStatus(string s) {
  const map = [
    "active": PolicyStatus.active,
    "inactive": PolicyStatus.inactive,
    "deleted": PolicyStatus.deleted_
  ];
  return map.get(s.toLower, PolicyStatus.inactive);
}

// ---------------------------------------------------------------------------
// Custom metric allow-from strategy
// ---------------------------------------------------------------------------
enum MetricAllowFrom {
  // Allow metric from the same application only
  sameApp,
  // Allow metric from any application bound to the same service instance
  boundApp,
}
MetricAllowFrom toMetricAllowFrom(string s) {
  const map = [
    "same_app": MetricAllowFrom.sameApp,
    "bound_app": MetricAllowFrom.boundApp
  ];
  return map.get(s.toLower, MetricAllowFrom.sameApp);
}
