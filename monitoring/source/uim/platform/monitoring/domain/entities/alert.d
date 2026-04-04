/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.alert;

import uim.platform.monitoring.domain.types;

/// An active or resolved alert triggered by a rule breach.
struct Alert {
  AlertId id;
  TenantId tenantId;
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
  string acknowledgedBy;
  string resolvedBy;
  long triggeredAt;
  long acknowledgedAt;
  long resolvedAt;
}
