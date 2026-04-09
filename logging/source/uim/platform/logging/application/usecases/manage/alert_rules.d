/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.alert_rules;

// import uim.platform.logging.domain.entities.alert_rule;
// import uim.platform.logging.domain.ports.repositories.alert_rules;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;
// 
// import std.conv : to;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageAlertRulesUseCase : UIMUseCase {
  private AlertRuleRepository repo;

  this(AlertRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateAlertRuleRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Alert rule name is required");

    AlertRule rule;
    rule.id = randomUUID().to!string;
    rule.tenantId = req.tenantId;
    rule.name = req.name;
    rule.description = req.description;
    rule.query = req.query;
    rule.condition = parseCondition(req.condition);
    rule.field = req.field;
    rule.pattern = req.pattern;
    rule.thresholdValue = req.thresholdValue;
    rule.thresholdOperator = parseOperator(req.thresholdOperator);
    rule.evaluationWindowSeconds = (req.evaluationWindowSeconds > 0) ? req.evaluationWindowSeconds : 300;
    rule.severity = parseSeverity(req.severity);
    rule.channelIds = cast(NotificationChannelId[]) req.channelIds;
    rule.isEnabled = true;
    rule.createdBy = req.createdBy;
    rule.createdAt = clockSeconds();

    repo.save(rule);
    return CommandResult(true, rule.id, "");
  }

  CommandResult update(AlertRuleId id, UpdateAlertRuleRequest req) {
    auto rule = repo.findById(id);
    if (rule.id.isEmpty)
      return CommandResult(false, "", "Alert rule not found");

    if (req.description.length > 0)
      rule.description = req.description;
    if (req.query.length > 0)
      rule.query = req.query;
    if (req.condition.length > 0)
      rule.condition = parseCondition(req.condition);
    if (req.field.length > 0)
      rule.field = req.field;
    if (req.pattern.length > 0)
      rule.pattern = req.pattern;
    if (req.thresholdValue != 0)
      rule.thresholdValue = req.thresholdValue;
    if (req.thresholdOperator.length > 0)
      rule.thresholdOperator = parseOperator(req.thresholdOperator);
    if (req.evaluationWindowSeconds > 0)
      rule.evaluationWindowSeconds = req.evaluationWindowSeconds;
    if (req.severity.length > 0)
      rule.severity = parseSeverity(req.severity);
    rule.isEnabled = req.isEnabled;
    if (req.channelIds.length > 0)
      rule.channelIds = cast(NotificationChannelId[]) req.channelIds;
    rule.updatedAt = clockSeconds();

    repo.update(rule);
    return CommandResult(true, id.toString, "");
  }

  AlertRule get_(AlertRuleId id) {
    return repo.findById(id);
  }

  AlertRule[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AlertRule[] listEnabled(TenantId tenantId) {
    return repo.findEnabled(tenantId);
  }

  CommandResult remove(AlertRuleId id) {
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private static AlertCondition parseCondition(string s) {
    switch (s) {
    case "contains":
      return AlertCondition.contains;
    case "regex":
      return AlertCondition.regex;
    case "threshold":
      return AlertCondition.threshold;
    case "absence":
      return AlertCondition.absence;
    case "rateChange":
      return AlertCondition.rateChange;
    default:
      return AlertCondition.contains;
    }
  }

  private static ThresholdOperator parseOperator(string s) {
    switch (s) {
    case "greaterThan":
      return ThresholdOperator.greaterThan;
    case "greaterOrEqual":
      return ThresholdOperator.greaterOrEqual;
    case "lessThan":
      return ThresholdOperator.lessThan;
    case "lessOrEqual":
      return ThresholdOperator.lessOrEqual;
    case "equal":
      return ThresholdOperator.equal;
    case "notEqual":
      return ThresholdOperator.notEqual;
    default:
      return ThresholdOperator.greaterThan;
    }
  }

  private static AlertSeverity parseSeverity(string s) {
    switch (s) {
    case "info":
      return AlertSeverity.info;
    case "warning":
      return AlertSeverity.warning;
    case "critical":
      return AlertSeverity.critical;
    case "fatal":
      return AlertSeverity.fatal;
    default:
      return AlertSeverity.warning;
    }
  }

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
