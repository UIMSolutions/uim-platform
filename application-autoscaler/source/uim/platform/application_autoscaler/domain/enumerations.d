/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.enumerations;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Metric types (standard)
// ---------------------------------------------------------------------------
enum MetricType : string {
  memoryused = "memoryused",
  memoryutil = "memoryutil",
  cpu = "cpu",
  cpuutil = "cpuutil",
  disk = "disk",
  diskutil = "diskutil",
  throughput = "throughput",
  responsetime = "responsetime",
  custom_ = "custom"
}
MetricType toMetricType(string s) {
  switch(s.toLower) {
    case "memoryused": return MetricType.memoryused;
    case "memoryutil": return MetricType.memoryutil;
    case "cpu":        return MetricType.cpu;
    case "cpuutil":    return MetricType.cpuutil;
    case "disk":       return MetricType.disk;
    case "diskutil":   return MetricType.diskutil;
    case "throughput": return MetricType.throughput;
    case "responsetime": return MetricType.responsetime;
    default:           return MetricType.custom_;
  }
}
MetricType toMetricType(Json value) {
  return toMetricType(value.getString);
}
MetricType[] toMetricTypes(string[] s) {
  return s.map!(toMetricType).array;
}
MetricType[] toMetricTypes(Json[] values) {
  return values.map!(toMetricType).array;
}
string toString(MetricType metricType) {
  return metricType.to!string;
}
string[] toStrings(MetricType[] metricTypes) {
  return metricTypes.map!toString.array;
}
Json toJson(MetricType metricType) {
  return metricType.toString.toJson;
}
Json[] toJson(MetricType[] metricTypes) {
  return metricTypes.map!(toJson).array;
}
///
unittest {
  mixin(ShowTest!("MetricType"));

  assert(MetricType.memoryused.toString == "memoryused");
  assert(MetricType.memoryutil.toString == "memoryutil");
  assert(MetricType.cpu.toString == "cpu");
  assert(MetricType.cpuutil.toString == "cpuutil");
  assert(MetricType.disk.toString == "disk");
  assert(MetricType.diskutil.toString == "diskutil");
  assert(MetricType.throughput.toString == "throughput");
  assert(MetricType.responsetime.toString == "responsetime");
  assert(MetricType.custom_.toString == "custom");

  assert("".toMetricType == MetricType.custom_); // Default case
  assert("noexists".toMetricType == MetricType.custom_); // Default case

  assert("memoryused".toMetricType == MetricType.memoryused);
  assert("memoryutil".toMetricType == MetricType.memoryutil);
  assert("cpu".toMetricType == MetricType.cpu);
  assert("cpuutil".toMetricType == MetricType.cpuutil);
  assert("disk".toMetricType == MetricType.disk);
  assert("diskutil".toMetricType == MetricType.diskutil);
  assert("throughput".toMetricType == MetricType.throughput);
  assert("responsetime".toMetricType == MetricType.responsetime);
  assert("custom".toMetricType == MetricType.custom_);

  assert(["memoryused", "memoryutil", "cpu", "cpuutil", "disk", "diskutil", "throughput", "responsetime", "custom"].toMetricTypes ==
         [MetricType.memoryused, MetricType.memoryutil, MetricType.cpu, MetricType.cpuutil, MetricType.disk, MetricType.diskutil, MetricType.throughput, MetricType.responsetime, MetricType.custom_]);
  assert(toStrings([MetricType.memoryused, MetricType.memoryutil, MetricType.cpu, MetricType.cpuutil, MetricType.disk, MetricType.diskutil, MetricType.throughput, MetricType.responsetime, MetricType.custom_]) ==
         ["memoryused", "memoryutil", "cpu", "cpuutil", "disk", "diskutil", "throughput", "responsetime", "custom"]); 
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
  switch(s.toLower) {
    case "<":  return ScalingOperator.lt;
    case ">":  return ScalingOperator.gt;
    case "<=": return ScalingOperator.lte;
    case ">=": return ScalingOperator.gte;
    case "lt": return ScalingOperator.lt;
    case "gt": return ScalingOperator.gt;
    case "lte": return ScalingOperator.lte;
    case "gte": return ScalingOperator.gte;
    default:   return ScalingOperator.gte;
  }
}
ScalingOperator[] toScalingOperators(string[] s) {
  return s.map!(toScalingOperator).array;
}
string toString(ScalingOperator op) {
  return op.to!string;
}
string[] toStrings(ScalingOperator[] ops) {
  return ops.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ScalingOperator"));

  assert(ScalingOperator.lt.toString == "lt");
  assert(ScalingOperator.gt.toString == "gt");
  assert(ScalingOperator.lte.toString == "lte");
  assert(ScalingOperator.gte.toString == "gte");

  assert("<".toScalingOperator == ScalingOperator.lt);
  assert(">".toScalingOperator == ScalingOperator.gt);
  assert("<=".toScalingOperator == ScalingOperator.lte);
  assert(">=".toScalingOperator == ScalingOperator.gte);
  assert("lt".toScalingOperator == ScalingOperator.lt);
  assert("gt".toScalingOperator == ScalingOperator.gt);
  assert("lte".toScalingOperator == ScalingOperator.lte);
  assert("gte".toScalingOperator == ScalingOperator.gte); 

  assert("noexists".toScalingOperator == ScalingOperator.gte); // Default case
  assert("".toScalingOperator == ScalingOperator.gte); // Default case

  assert(["<", ">", "<=", ">=", "lt", "gt", "lte", "gte"].toScalingOperators ==
         [ScalingOperator.lt, ScalingOperator.gt, ScalingOperator.lte, ScalingOperator.gte, ScalingOperator.lt, ScalingOperator.gt, ScalingOperator.lte, ScalingOperator.gte]);
  assert(toStrings([ScalingOperator.lt, ScalingOperator.gt, ScalingOperator.lte, ScalingOperator.gte]) ==
         ["lt", "gt", "lte", "gte"]);
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
ScalingDirection toScalingDirection(string value) {
  mixin(EnumSwitch("ScalingDirection", "none"));
}
ScalingDirection[] toScalingDirections(string[] s) {
  return s.map!(toScalingDirection).array;
}
string toString(ScalingDirection direction) {
  return direction.to!string;
}
string[] toStrings(ScalingDirection[] directions) {
  return directions.map!toString.array;
} 
/// 
unittest {
  mixin(ShowTest!("ScalingDirection"));

  assert(ScalingDirection.scaleOut.toString == "scaleOut");
  assert(ScalingDirection.scaleIn.toString == "scaleIn");
  assert(ScalingDirection.none.toString == "none");

  assert("scaleOut".toScalingDirection == ScalingDirection.scaleOut);
  assert("scaleIn".toScalingDirection == ScalingDirection.scaleIn);
  assert("none".toScalingDirection == ScalingDirection.none);

  assert("noexists".toScalingDirection == ScalingDirection.none); // Default case
  assert("".toScalingDirection == ScalingDirection.none); // Default case

  assert(["scaleOut", "scaleIn", "none"].toScalingDirections ==
         [ScalingDirection.scaleOut, ScalingDirection.scaleIn, ScalingDirection.none]);
  assert(toStrings([ScalingDirection.scaleOut, ScalingDirection.scaleIn, ScalingDirection.none]) ==
         ["scaleOut", "scaleIn", "none"]);
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
ScalingStatus toScalingStatus(string value) {
  mixin(EnumSwitch("ScalingStatus", "ignored"));
}
ScalingStatus[] toScalingStatuses(string[] s) {
  return s.map!(toScalingStatus).array;
}
string toString(ScalingStatus status) {
  return status.to!string;
}
string[] toStrings(ScalingStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ScalingStatus"));

  assert(ScalingStatus.succeeded.toString == "succeeded");
  assert(ScalingStatus.failed.toString == "failed");
  assert(ScalingStatus.ignored.toString == "ignored");

  assert("succeeded".toScalingStatus == ScalingStatus.succeeded);
  assert("failed".toScalingStatus == ScalingStatus.failed);
  assert("ignored".toScalingStatus == ScalingStatus.ignored);

  assert("noexists".toScalingStatus == ScalingStatus.ignored); // Default case
  assert("".toScalingStatus == ScalingStatus.ignored); // Default case

  assert(["succeeded", "failed", "ignored"].toScalingStatuses ==
         [ScalingStatus.succeeded, ScalingStatus.failed, ScalingStatus.ignored]);
  assert(toStrings([ScalingStatus.succeeded, ScalingStatus.failed, ScalingStatus.ignored]) ==
         ["succeeded", "failed", "ignored"]);
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
  switch(s.toLower) {
    case "active": return PolicyStatus.active;
    case "inactive": return PolicyStatus.inactive;
    case "deleted": return PolicyStatus.deleted_;
    default: return PolicyStatus.inactive;
  }
}
PolicyStatus[] toPolicyStatuses(string[] s) {
  return s.map!(toPolicyStatus).array;
}
string toString(PolicyStatus status) {
  return status.to!string;
}
string[] toStrings(PolicyStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("PolicyStatus"));

  assert(PolicyStatus.active.toString == "active");
  assert(PolicyStatus.inactive.toString == "inactive");
  assert(PolicyStatus.deleted_.toString == "deleted"); 
  assert("active".toPolicyStatus == PolicyStatus.active);
  assert("inactive".toPolicyStatus == PolicyStatus.inactive);
  assert("deleted".toPolicyStatus == PolicyStatus.deleted_);

  assert("noexists".toPolicyStatus == PolicyStatus.inactive); // Default case
  assert("".toPolicyStatus == PolicyStatus.inactive); // Default case

  assert(["active", "inactive", "deleted"].toPolicyStatuses ==
         [PolicyStatus.active, PolicyStatus.inactive, PolicyStatus.deleted_]);
  assert([PolicyStatus.active, PolicyStatus.inactive, PolicyStatus.deleted_].toStrings ==
         ["active", "inactive", "deleted"]);
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
MetricAllowFrom toMetricAllowFrom(string value) {
  mixin(EnumSwitch("MetricAllowFrom", "sameApp"));
}
MetricAllowFrom[] toMetricAllowFroms(string[] s) {
  return s.map!(toMetricAllowFrom).array;
}
string toString(MetricAllowFrom allowFrom) {
  return allowFrom.to!string;
}
string[] toStrings(MetricAllowFrom[] allowFroms) {
  return allowFroms.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("MetricAllowFrom"));

  assert(MetricAllowFrom.sameApp.toString == "sameApp");
  assert(MetricAllowFrom.boundApp.toString == "boundApp");

  assert("sameApp".toMetricAllowFrom == MetricAllowFrom.sameApp);
  assert("boundApp".toMetricAllowFrom == MetricAllowFrom.boundApp);

  assert("noexists".toMetricAllowFrom == MetricAllowFrom.sameApp); // Default case
  assert("".toMetricAllowFrom == MetricAllowFrom.sameApp); // Default case

  assert(["sameApp", "boundApp"].toMetricAllowFroms ==
         [MetricAllowFrom.sameApp, MetricAllowFrom.boundApp]);
  assert([MetricAllowFrom.sameApp, MetricAllowFrom.boundApp].toStrings ==
         ["sameApp", "boundApp"]);
}
