/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.alert_rule;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// An alert rule that defines thresholds for triggering alerts.
struct AlertRule {
  mixin TenantEntity!(AlertRuleId);

  MonitoredResourceId resourceId;
  string name;
  string description;
  string metricName;
  MetricDefinitionId metricDefinitionId;
  ThresholdOperator operator_ = ThresholdOperator.greaterThan;
  double warningThreshold;
  double criticalThreshold;
  int evaluationPeriodSeconds = 300;
  int consecutiveBreaches = 1;
  AlertSeverity severity = AlertSeverity.warning;
  bool isEnabled = true;
  NotificationChannelId[] channelIds;

  Json toJson() const {
    auto j = entityToJson
      .set("resourceId", resourceId.value)
      .set("name", name)
      .set("description", description)
      .set("metricName", metricName)
      .set("metricDefinitionId", metricDefinitionId.value)
      .set("operator", operator_.to!string)
      .set("warningThreshold", warningThreshold)
      .set("criticalThreshold", criticalThreshold)
      .set("evaluationPeriodSeconds", evaluationPeriodSeconds)
      .set("consecutiveBreaches", consecutiveBreaches)
      .set("severity", severity.to!string)
      .set("isEnabled", isEnabled)
      .set("channelIds", channelIds.map!(id => id.value).array);

    return j;
  }
}
