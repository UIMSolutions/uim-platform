/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.scaling_rule;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// A single dynamic scaling rule within a policy.
/// Based on SAP Application Autoscaler rule parameters.
struct ScalingRuleEntity {
  mixin TenantEntity!ScalingRuleId;

  MetricType    metricType;
  string        customMetricName;   // only when metricType == custom_
  int           threshold;
  ScalingOperator operator;
  int           breachDurationSecs; // 60-3600, default 120
  int           coolDownSecs;       // 60-3600, default 300
  string        adjustment;         // e.g. "+1", "-2", "+100%"

  Json toJson() const @safe {
    return entityToJson  
    .set("metric_type", metricType.to!string)
    .set("custom_metric_name", customMetricName)
    .set("threshold", threshold)
    .set("operator", operator.to!string)
    .set("breach_duration_secs", breachDurationSecs)
    .set("cool_down_secs", coolDownSecs)
    .set("adjustment", adjustment);
  }
}
