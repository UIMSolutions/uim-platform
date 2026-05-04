/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.alert;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// An active or resolved alert triggered by a rule breach.
struct Alert {
  mixin TenantEntity!(AlertId);
  
  AlertRuleId ruleId;
  MonitoredResourceId resourceId;
  string ruleName;
  string metricName;
  double currentValue;
  double thresholdValue;
  ThresholdOperator operator_;
  AlertSeverity severity = AlertSeverity.warning;
  AlertState state = AlertState.open;
  string message;
  UserId acknowledgedBy;
  UserId resolvedBy;
  long triggeredAt;
  long acknowledgedAt;
  long resolvedAt;

  Json toJson() const {
    return entityToJson
      .set("ruleId", ruleId.value)
      .set("resourceId", resourceId.value)
      .set("ruleName", ruleName)
      .set("metricName", metricName)
      .set("currentValue", currentValue)
      .set("thresholdValue", thresholdValue)
      .set("operator", operator_.to!string())
      .set("severity", severity.to!string())
      .set("state", state.to!string())
      .set("message", message)
      .set("acknowledgedBy", acknowledgedBy)
      .set("resolvedBy", resolvedBy)
      .set("triggeredAt", triggeredAt)
      .set("acknowledgedAt", acknowledgedAt)
      .set("resolvedAt", resolvedAt);
  }
}
