/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.alert_rule;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct AlertRule {
  AlertRuleId id;
  TenantId tenantId;
  string name;
  string description;
  string query;
  AlertCondition condition = AlertCondition.contains;
  string field;
  string pattern;
  double thresholdValue;
  ThresholdOperator thresholdOperator = ThresholdOperator.greaterThan;
  int evaluationWindowSeconds = 300;
  AlertSeverity severity = AlertSeverity.warning;
  NotificationChannelId[] channelIds;
  bool isEnabled = true;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}
