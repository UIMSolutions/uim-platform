/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.application_autoscaler.domain.enumerations.autoscaler;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// Metric of a dynamic scaling rule (SAP Application Autoscaler names).
enum MetricType : string {
  cpu = "cpu", /// CPU usage of the instances (%)
  cpuUtil = "cpuutil", /// CPU utilization relative to the entitlement (%)
  memoryUsed = "memoryused", /// memory used (MB)
  memoryUtil = "memoryutil", /// memory used relative to the quota (%)
  disk = "disk", /// disk used (MB)
  diskUtil = "diskutil", /// disk used relative to the quota (%)
  throughput = "throughput", /// requests per second
  responseTime = "responsetime", /// average response time (ms)
  custom = "custom" /// a custom metric submitted by the application (customMetricName)
}

/// Metrics measured in percent (threshold 1 .. 100).
bool isPercentMetric(MetricType m) pure {
  return m == MetricType.cpu || m == MetricType.cpuUtil || m == MetricType.memoryUtil || m == MetricType.diskUtil;
}

/// Unit shown for a standard metric.
string metricUnit(MetricType m) pure {
  final switch (m) {
  case MetricType.cpu, MetricType.cpuUtil, MetricType.memoryUtil, MetricType.diskUtil:
    return "%";
  case MetricType.memoryUsed, MetricType.disk:
    return "MB";
  case MetricType.throughput:
    return "rps";
  case MetricType.responseTime:
    return "ms";
  case MetricType.custom:
    return "";
  }
}

/// Comparison of a rule's metric with its threshold.
enum ComparisonOperator : string {
  lt = "<",
  lte = "<=",
  gt = ">",
  gte = ">="
}

/// "gt", ">", "GTE", ">=" … → operator. Throws invalid.
ComparisonOperator parseOperator(string text) {
  switch (text.strip.toLower) {
  case "<", "lt":
    return ComparisonOperator.lt;
  case "<=", "lte", "le":
    return ComparisonOperator.lte;
  case ">", "gt":
    return ComparisonOperator.gt;
  case ">=", "gte", "ge":
    return ComparisonOperator.gte;
  default:
    throw AasException.invalid("Invalid operator '" ~ text ~ "' (allowed: <, <=, >, >=)");
  }
}

bool compare(ComparisonOperator op, double value, double threshold) pure {
  final switch (op) {
  case ComparisonOperator.lt:
    return value < threshold;
  case ComparisonOperator.lte:
    return value <= threshold;
  case ComparisonOperator.gt:
    return value > threshold;
  case ComparisonOperator.gte:
    return value >= threshold;
  }
}

/// Whether a policy is evaluated.
enum PolicyStatus : string {
  active = "active",
  inactive = "inactive"
}

/// Which applications may submit custom metrics for a binding.
enum MetricAllowFrom : string {
  sameApp = "sameApp", /// only the bound application itself
  boundApp = "boundApp" /// any application bound to the same service instance
}

/// Autoscaling state of a binding.
enum BindingStatus : string {
  active = "active", /// evaluated by the scaling engine
  suspended = "suspended" /// autoscaling paused (manual scaling still possible)
}

/// Kind of a schedule.
enum ScheduleKind : string {
  recurring = "recurring", /// every week (daysOfWeek) or month (daysOfMonth) between startTime and endTime
  specificDate = "specificDate" /// once, from startDateTime to endDateTime
}

/// What caused a scaling decision.
enum ScalingTrigger : string {
  dynamic = "dynamic", /// a breached scaling rule
  schedule = "schedule", /// the instance limits of an active schedule
  limits = "limits", /// the instance limits of the policy
  manual = "manual" /// an operator
}

enum ScalingDirection : string {
  scaleOut = "scaleOut",
  scaleIn = "scaleIn",
  none = "none"
}

enum ScalingStatus : string {
  succeeded = "succeeded", /// the instance count was changed
  failed = "failed", /// the platform refused the change
  ignored = "ignored" /// nothing to do (no breach, cool-down, limits reached)
}

///
unittest {
  assert(parseOperator("GT") == ComparisonOperator.gt && parseOperator(">=") == ComparisonOperator.gte);
  assert(failsWith(AasErrorKind.invalid, () { parseOperator("=="); }));
  assert(compare(ComparisonOperator.gte, 80, 80) && !compare(ComparisonOperator.gt, 80, 80));
  assert(compare(ComparisonOperator.lt, 10, 30) && isPercentMetric(MetricType.cpu) && !isPercentMetric(MetricType.throughput));
  assert(metricUnit(MetricType.responseTime) == "ms");
}
