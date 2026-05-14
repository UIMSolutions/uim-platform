/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.types;

// ---------------------------------------------------------------------------
// ID type aliases
// ---------------------------------------------------------------------------
alias PolicyId           = string;
alias ScalingRuleId      = string;
alias ScheduleId         = string;
alias RecurringScheduleId = string;
alias SpecificDateScheduleId = string;
alias CustomMetricId     = string;
alias ScalingHistoryId   = string;
alias AppBindingId       = string;
alias TenantId           = string;

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

string metricTypeToString(MetricType m) @safe {
  final switch (m) {
    case MetricType.memoryused:    return "memoryused";
    case MetricType.memoryutil:    return "memoryutil";
    case MetricType.cpu:           return "cpu";
    case MetricType.cpuutil:       return "cpuutil";
    case MetricType.disk:          return "disk";
    case MetricType.diskutil:      return "diskutil";
    case MetricType.throughput:    return "throughput";
    case MetricType.responsetime:  return "responsetime";
    case MetricType.custom_:       return "custom";
  }
}

MetricType parseMetricType(string s) @safe {
  import std.uni : toLower;
  switch (s.toLower) {
    case "memoryused":   return MetricType.memoryused;
    case "memoryutil":   return MetricType.memoryutil;
    case "cpu":          return MetricType.cpu;
    case "cpuutil":      return MetricType.cpuutil;
    case "disk":         return MetricType.disk;
    case "diskutil":     return MetricType.diskutil;
    case "throughput":   return MetricType.throughput;
    case "responsetime": return MetricType.responsetime;
    default:             return MetricType.custom_;
  }
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

string scalingOperatorToString(ScalingOperator op) @safe {
  final switch (op) {
    case ScalingOperator.lt:  return "<";
    case ScalingOperator.gt:  return ">";
    case ScalingOperator.lte: return "<=";
    case ScalingOperator.gte: return ">=";
  }
}

ScalingOperator parseScalingOperator(string s) @safe {
  switch (s) {
    case "<":  return ScalingOperator.lt;
    case ">":  return ScalingOperator.gt;
    case "<=": return ScalingOperator.lte;
    case ">=": return ScalingOperator.gte;
    default:   return ScalingOperator.gte;
  }
}

// ---------------------------------------------------------------------------
// Scaling direction result
// ---------------------------------------------------------------------------
enum ScalingDirection {
  scaleOut,
  scaleIn,
  none,
}

// ---------------------------------------------------------------------------
// Scaling event status
// ---------------------------------------------------------------------------
enum ScalingStatus {
  succeeded,
  failed,
  ignored,
}

// ---------------------------------------------------------------------------
// Policy status
// ---------------------------------------------------------------------------
enum PolicyStatus {
  active,
  inactive,
  deleted_,
}

// ---------------------------------------------------------------------------
// Custom metric allow-from strategy
// ---------------------------------------------------------------------------
enum MetricAllowFrom {
  sameApp,
  boundApp,
}

string metricAllowFromToString(MetricAllowFrom m) @safe {
  final switch (m) {
    case MetricAllowFrom.sameApp:  return "same_app";
    case MetricAllowFrom.boundApp: return "bound_app";
  }
}
