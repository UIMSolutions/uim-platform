/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.alert_rule;

import uim.platform.monitoring.domain.types;

/// An alert rule that defines thresholds for triggering alerts.
struct AlertRule
{
  AlertRuleId id;
  TenantId tenantId;
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
  string createdBy;
  long createdAt;
  long updatedAt;
}
