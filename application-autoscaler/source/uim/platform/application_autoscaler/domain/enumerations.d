module uim.platform.application_autoscaler.domain.enumerations;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

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

string toString(MetricType m) {
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

MetricType toMetricType(string s) {
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

string toString(ScalingOperator op) {
  final switch (op) {
    case ScalingOperator.lt:  return "<";
    case ScalingOperator.gt:  return ">";
    case ScalingOperator.lte: return "<=";
    case ScalingOperator.gte: return ">=";
  }
}

ScalingOperator toScalingOperator(string s) {
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

string toString(ScalingDirection d) {
  final switch (d) {
    case ScalingDirection.scaleOut: return "scale_out";
    case ScalingDirection.scaleIn:  return "scale_in";
    case ScalingDirection.none:     return "none";
  }
}

ScalingDirection toScalingDirection(string s) {
  import std.uni : toLower;
  switch (s.toLower) {
    case "scale_out": return ScalingDirection.scaleOut;
    case "scale_in":  return ScalingDirection.scaleIn;
    default:          return ScalingDirection.none;
  }
}


// ---------------------------------------------------------------------------
// Scaling event status
// ---------------------------------------------------------------------------
enum ScalingStatus {
  succeeded,
  failed,
  ignored,
}

string toString(ScalingStatus s) {
  final switch (s) {
    case ScalingStatus.succeeded: return "succeeded";
    case ScalingStatus.failed:    return "failed";
    case ScalingStatus.ignored:   return "ignored";
  }
}

ScalingStatus toScalingStatus(string s) {
  import std.uni : toLower;
  switch (s.toLower()) {
    case "succeeded": return ScalingStatus.succeeded;
    case "failed":    return ScalingStatus.failed;
    case "ignored":   return ScalingStatus.ignored;
    default:          return ScalingStatus.ignored;
  }
}

// ---------------------------------------------------------------------------
// Policy status
// ---------------------------------------------------------------------------
enum PolicyStatus {
  active,
  inactive,
  deleted_,
}

string toString(PolicyStatus s) {
  final switch (s) {
    case PolicyStatus.active:   return "active";
    case PolicyStatus.inactive: return "inactive";
    case PolicyStatus.deleted_: return "deleted";
  }
}

PolicyStatus toPolicyStatus(string s) {
  import std.uni : toLower;
  switch (s.toLower()) {
    case "active":   return PolicyStatus.active;
    case "inactive": return PolicyStatus.inactive;
    case "deleted":  return PolicyStatus.deleted_;
    default:         return PolicyStatus.active;
  }
}

// ---------------------------------------------------------------------------
// Custom metric allow-from strategy
// ---------------------------------------------------------------------------
enum MetricAllowFrom {
  sameApp,
  boundApp,
}

string toString(MetricAllowFrom m) {
  final switch (m) {
    case MetricAllowFrom.sameApp:  return "same_app";
    case MetricAllowFrom.boundApp: return "bound_app";
  }
}

MetricAllowFrom toMetricAllowFrom(string s) {
  import std.uni : toLower;
  switch (s.toLower) {
    case "same_app":  return MetricAllowFrom.sameApp;
    case "bound_app": return MetricAllowFrom.boundApp;
    default:          return MetricAllowFrom.sameApp;
  }
}
