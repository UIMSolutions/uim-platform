/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.alert_rules;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.alert_rule;
// import uim.platform.monitoring.domain.ports.repositories.alert_rules;
// import uim.platform.monitoring.domain.types;
// 
import uim.platform.monitoring;
mixin(ShowModule!());

@safe:
/// Application service for alert rule CRUD (thresholds and checks configuration).
class ManageAlertRulesUseCase { // TODO: UIMUseCase {
  private AlertRuleRepository alertRules;

  this(AlertRuleRepository alertRules) {
    this.alertRules = alertRules;
  }

  CommandResult createRule(CreateAlertRuleRequest req) {
    if (req.name.isEmpty)
      return CommandResult(false, "", "Rule name is required");

    if (req.metricname.isEmpty)
      return CommandResult(false, "", "Metric name is required");

    auto rule = AlertRule(req.tenantId); //, UserId("test-user"));
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
    rule.severity = req.severity.toAlertSeverity;
    rule.isEnabled = true;
    rule.channelIds = req.channelIds;

    alertRules.save(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateRule(UpdateAlertRuleRequest req) {
    auto rule = alertRules.findById(req.tenantId, req.alertRuleId);
    if (rule.isNull)
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
      rule.severity = req.severity.toAlertSeverity;
    rule.isEnabled = req.isEnabled;
    if (req.channelIds.length > 0)
      rule.channelIds = req.channelIds;
    rule.updatedAt = clockSeconds();

    alertRules.update(rule);
    return CommandResult(true, rule.id.value, "");
  }

  AlertRule getRule(TenantId tenantId, AlertRuleId id) {
    return alertRules.findById(tenantId, id);
  }

  AlertRule[] listRules(TenantId tenantId) {
    return alertRules.findByTenant(tenantId);
  }

  AlertRule[] listByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return alertRules.findByResource(tenantId, resourceId);
  }

  AlertRule[] listEnabled(TenantId tenantId) {
    return alertRules.findEnabled(tenantId);
  }

  CommandResult deleteRule(TenantId tenantId, AlertRuleId id) {
    auto rule = alertRules.findById(tenantId, id);
    if (rule.isNull)
      return CommandResult(false, "", "Alert rule not found");

    alertRules.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }

  private static ThresholdOperator parseOperator(string thresholdOperator) {
    switch (thresholdOperator) {
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
}
