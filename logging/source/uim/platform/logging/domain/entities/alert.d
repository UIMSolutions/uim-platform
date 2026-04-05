/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.alert;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct Alert {
  AlertId id;
  TenantId tenantId;
  AlertRuleId ruleId;
  string ruleName;
  AlertSeverity severity = AlertSeverity.warning;
  AlertState state = AlertState.open;
  string message;
  long matchCount;
  LogEntryId sampleLogEntryId;
  string acknowledgedBy;
  string resolvedBy;
  long triggeredAt;
  long acknowledgedAt;
  long resolvedAt;
}
