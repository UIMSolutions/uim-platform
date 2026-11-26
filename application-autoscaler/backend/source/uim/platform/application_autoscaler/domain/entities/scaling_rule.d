/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A dynamic scaling rule of a policy: when the metric compared with the
/// threshold holds for breachDurationSeconds, adjust the instances; then
/// wait coolDownSeconds before the next dynamic scaling of the application.
module uim.platform.application_autoscaler.domain.entities.scaling_rule;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum int minBreachSeconds = 60;
enum int maxBreachSeconds = 3600;
enum int minCoolDownSeconds = 60;
enum int maxCoolDownSeconds = 3600;

struct ScalingRule {
  mixin TenantEntity!ScalingRuleId;

  ScalingPolicyId policyId;
  MetricType metricType = MetricType.cpu;
  string customMetricName; /// only for metricType custom
  ComparisonOperator operator = ComparisonOperator.gte;
  double threshold = 80;
  int breachDurationSeconds = 120;
  int coolDownSeconds = 300;
  string adjustment = "+1"; /// "+1", "-2", "+50%", "-25%"
  bool enabled = true;

  /// The metric name the samples are matched on ("cpu", "jobqueue", …).
  string metricName() const {
    return metricType == MetricType.custom ? customMetricName : cast(string) metricType;
  }

  Adjustment parsedAdjustment() const {
    return parseAdjustment(adjustment);
  }

  ScalingDirection direction() const {
    return parsedAdjustment.scalesOut ? ScalingDirection.scaleOut : ScalingDirection.scaleIn;
  }

  /// "cpu >= 80 for 120s → +1"
  string summary() const {
    return format("%s %s %s for %ds → %s", metricName, cast(string) operator, threshold.to!string,
      breachDurationSeconds, adjustment);
  }

  void validate() const {
    requireId(id.value, "Rule ID");
    if (policyId.isNull)
      throw AasException.invalid("Policy is required");
    if (metricType == MetricType.custom) {
      requireText(customMetricName, "Custom metric name");
      if (!isValidMetricName(customMetricName))
        throw AasException.invalid("Custom metric name '" ~ customMetricName
            ~ "' is invalid (1-100 characters: letters, digits, '_', '-', '.')");
      if (domainEnumValues!MetricType.canFind(customMetricName.toLower))
        throw AasException.invalid("Custom metric name '" ~ customMetricName ~ "' is a standard metric; use that metric type");
    } else if (customMetricName.length)
      throw AasException.invalid("A custom metric name is only allowed for the metric type 'custom'");
    import std.math : isFinite;

    if (!isFinite(threshold))
      throw AasException.invalid("Threshold must be a number");
    if (isPercentMetric(metricType) && (threshold < 1 || threshold > 100))
      throw AasException.invalid("The threshold of '" ~ cast(string) metricType ~ "' is a percentage (1 to 100)");
    if (threshold < 0)
      throw AasException.invalid("Threshold must not be negative");
    requireRange(breachDurationSeconds, minBreachSeconds, maxBreachSeconds, "Breach duration (seconds)");
    requireRange(coolDownSeconds, minCoolDownSeconds, maxCoolDownSeconds, "Cool-down (seconds)");
    parseAdjustment(adjustment);
  }
}

/// Names of submitted metrics: 1-100 of [A-Za-z0-9_.-].
bool isValidMetricName(string name) pure {
  if (name.length == 0 || name.length > 100)
    return false;
  foreach (c; name)
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.'))
      return false;
  return true;
}

///
unittest {
  ScalingRule r;
  r.id = ScalingRuleId("r");
  r.policyId = ScalingPolicyId("p");
  r.validate();
  assert(r.metricName == "cpu" && r.direction == ScalingDirection.scaleOut && r.summary == "cpu >= 80 for 120s → +1");
  r.adjustment = "-1";
  r.operator = ComparisonOperator.lt;
  r.threshold = 20;
  assert(r.direction == ScalingDirection.scaleIn);
  r.threshold = 150;
  assert(failsWith(AasErrorKind.invalid, () { r.validate(); }));
  r.metricType = MetricType.custom;
  r.threshold = 150;
  assert(failsWith(AasErrorKind.invalid, () { r.validate(); }));
  r.customMetricName = "jobqueue";
  r.validate();
  assert(r.metricName == "jobqueue");
  r.customMetricName = "cpu";
  assert(failsWith(AasErrorKind.invalid, () { r.validate(); }));
  r.customMetricName = "jobqueue";
  r.breachDurationSeconds = 10;
  assert(failsWith(AasErrorKind.invalid, () { r.validate(); }));
}
