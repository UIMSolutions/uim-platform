/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.alert_rules;

import uim.platform.monitoring.application.dto;
import uim.platform.monitoring.domain.entities.alert_rule;
import uim.platform.monitoring.domain.ports.repositories.alert_rules;
import uim.platform.monitoring.domain.types;

// import std.conv : to;

/// Application service for alert rule CRUD (thresholds and checks configuration).
class ManageAlertRulesUseCase
{
  private AlertRuleRepository repo;

  this(AlertRuleRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createRule(CreateAlertRuleRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Rule name is required");

    if (req.metricName.length == 0)
      return CommandResult(false, "", "Metric name is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    AlertRule rule;
    rule.id = id;
    rule.tenantId = req.tenantId;
    rule.resourceId = req.resourceId;
    rule.name = req.name;
    rule.description = req.description;
    rule.metricName = req.metricName;
    rule.metricDefinitionId = req.metricDefinitionId;
    rule.operator_ = parseOperator(req.operator_);
    rule.warningThreshold = req.warningThreshold;
    rule.criticalThreshold = req.criticalThreshold;
    rule.evaluationPeriodSeconds = req.evaluationPeriodSeconds > 0 ? req.evaluationPeriodSeconds
      : 300;
    rule.consecutiveBreaches = req.consecutiveBreaches > 0 ? req.consecutiveBreaches : 1;
    rule.severity = parseSeverity(req.severity);
    rule.isEnabled = true;
    rule.channelIds = req.channelIds;
    rule.createdBy = req.createdBy;
    rule.createdAt = clockSeconds();
    rule.updatedAt = rule.createdAt;

    repo.save(rule);
    return CommandResult(true, id, "");
  }

  CommandResult updateRule(AlertRuleId id, UpdateAlertRuleRequest req)
  {
    auto rule = repo.findById(id);
    if (rule.id.length == 0)
      return CommandResult(false, "", "Alert rule not found");

    if (req.description.length > 0)
      rule.description = req.description;
    if (req.warningThreshold != 0)
      rule.warningThreshold = req.warningThreshold;
    if (req.criticalThreshold != 0)
      rule.criticalThreshold = req.criticalThreshold;
    if (req.evaluationPeriodSeconds > 0)
      rule.evaluationPeriodSeconds = req.evaluationPeriodSeconds;
    if (req.consecutiveBreaches > 0)
      rule.consecutiveBreaches = req.consecutiveBreaches;
    if (req.severity.length > 0)
      rule.severity = parseSeverity(req.severity);
    rule.isEnabled = req.isEnabled;
    if (req.channelIds.length > 0)
      rule.channelIds = req.channelIds;
    rule.updatedAt = clockSeconds();

    repo.update(rule);
    return CommandResult(true, id, "");
  }

  AlertRule getRule(AlertRuleId id)
  {
    return repo.findById(id);
  }

  AlertRule[] listRules(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  AlertRule[] listByResource(TenantId tenantId, MonitoredResourceId resourceId)
  {
    return repo.findByResource(tenantId, resourceId);
  }

  AlertRule[] listEnabled(TenantId tenantId)
  {
    return repo.findEnabled(tenantId);
  }

  CommandResult deleteRule(AlertRuleId id)
  {
    auto rule = repo.findById(id);
    if (rule.id.length == 0)
      return CommandResult(false, "", "Alert rule not found");

    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private static long clockSeconds()
  {
    // import std.datetime.systime : Clock;
    return Clock.currTime().toUnixTime();
  }

  private static ThresholdOperator parseOperator(string s)
  {
    switch (s)
    {
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

  private static AlertSeverity parseSeverity(string s)
  {
    switch (s)
    {
    case "info":
      return AlertSeverity.info;
    case "critical":
      return AlertSeverity.critical;
    case "fatal":
      return AlertSeverity.fatal;
    default:
      return AlertSeverity.warning;
    }
  }
}
