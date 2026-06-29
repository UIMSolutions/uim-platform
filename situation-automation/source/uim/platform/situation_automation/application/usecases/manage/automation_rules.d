/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.automation_rules;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
class ManageAutomationRulesUseCase { // TODO: UIMUseCase {
    private AutomationRuleRepository repo;

    this(AutomationRuleRepository repo) {
        this.repo = repo;
    }

    CommandResult createAutomationRule(CreateAutomationRuleRequest r) {
        auto err = SituationEvaluator.validate(r.tenantId, r.automationRuleId.value, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.find(r.tenantId, r.automationRuleId);
        if (!existing.isNull)
            return CommandResult(false, "", "Automation rule already exists");

        AutomationRule rule;
        rule.initEntity(r.tenantId, r.automationRuleId, r.createdBy);
        rule.situationTemplateId = r.situationTemplateId;
        rule.name = r.name;
        rule.description = r.description;
        rule.status = RuleStatus.draft;
        rule.executionOrder = r.executionOrder;
        rule.enabled = true;

        repo.save(rule);
        return CommandResult(true, rule.id.value, "");
    }

    AutomationRule getAutomationRule(TenantId tenantId, AutomationRuleId id) {
        return repo.findById(tenantId, id);
    }

    AutomationRule[] listAutomationRules(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AutomationRule[] listAutomationRules(TenantId tenantId, SituationTemplateId templateId) {
        return repo.findByTemplate(tenantId, templateId);
    }

    AutomationRule[] listActiveAutomationRules(TenantId tenantId) {
        return repo.findActive(tenantId);
    }

    CommandResult updateAutomationRule(UpdateAutomationRuleRequest r) {
        auto rule = repo.find(r.tenantId, r.automationRuleId);
        if (rule.isNull)
            return CommandResult(false, "", "Automation rule not found");

        rule.updatedAt = currentTimestamp();
        rule.name = r.name;
        rule.description = r.description;
        rule.executionOrder = r.executionOrder;
        rule.enabled = r.enabled;

        repo.update(rule);
        return CommandResult(true, rule.id.value, "");
    }

    CommandResult deleteAutomationRule(TenantId tenantId, AutomationRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Automation rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }
}
