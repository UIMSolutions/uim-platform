/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.alert_rules;
// import uim.platform.logging.domain.entities.alert_rule;
// import uim.platform.logging.domain.ports.repositories.alert_rules;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageAlertRulesUseCase { // TODO: UIMUseCase {
  private AlertRuleRepository repo;

  this(AlertRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult createAlertRule(CreateAlertRuleRequest req) {
    if (req.name.isEmpty)
      return CommandResult(false, "", "Alert rule name is required");

    auto rule = AlertRule(req.tenantId); //, req.createdBy);
    rule.name = req.name;
    rule.description = req.description;
    rule.query = req.query;
    rule.condition = req.condition.to!AlertCondition;
    rule.field = req.field;
    rule.pattern = req.pattern;
    rule.thresholdValue = req.thresholdValue;
    rule.thresholdOperator = req.thresholdOperator.to!ThresholdOperator;
    rule.evaluationWindowSeconds = (req.evaluationWindowSeconds > 0) ? req.evaluationWindowSeconds : 300;
    rule.severity = req.severity.to!AlertSeverity;
    rule.channelIds = cast(NotificationChannelId[]) req.channelIds;
    rule.isEnabled = true;

    repo.save(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateAlertRule(UpdateAlertRuleRequest req) {
    auto rule = repo.findById(req.tenantId, req.ruleId);
    if (rule.isNull)
      return CommandResult(false, "", "Alert rule not found");

    if (req.description.length > 0)
      rule.description = req.description;
    if (req.query.length > 0)
      rule.query = req.query;
    if (req.condition.length > 0)
      rule.condition = req.condition.to!AlertCondition;
    if (req.field.length > 0)
      rule.field = req.field;
    if (req.pattern.length > 0)
      rule.pattern = req.pattern;
    if (req.thresholdValue != 0)
      rule.thresholdValue = req.thresholdValue;
    if (req.thresholdOperator.length > 0)
      rule.thresholdOperator = req.thresholdOperator.to!ThresholdOperator;
    if (req.evaluationWindowSeconds > 0)
      rule.evaluationWindowSeconds = req.evaluationWindowSeconds;
    if (req.severity.length > 0)
      rule.severity = req.severity.to!AlertSeverity;
    rule.isEnabled = req.isEnabled;
    if (req.channelIds.length > 0)
      rule.channelIds = cast(NotificationChannelId[]) req.channelIds;
    rule.updatedAt = clockSeconds();

    repo.update(rule);
    return CommandResult(true, rule.id.value, "");
  }

  bool hasRule(TenantId tenantId, AlertRuleId id) {
    return repo.existsById(tenantId, id);
  }

  AlertRule getRule(TenantId tenantId, AlertRuleId ruleId) {
    return repo.findById(tenantId, ruleId);
  }

  AlertRule[] listRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  AlertRule[] listEnabledRules(TenantId tenantId) {
    return repo.findEnabled(tenantId);
  }

  CommandResult deleteAlertRule(TenantId tenantId, AlertRuleId id) {
    auto rule = repo.findById(tenantId, id);
    if (rule.isNull)
      return CommandResult(false, "", "Alert rule not found");

    repo.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }
  
}
