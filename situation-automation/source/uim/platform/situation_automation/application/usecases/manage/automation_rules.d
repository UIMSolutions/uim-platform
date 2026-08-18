/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.automation_rules;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageAutomationRulesUseCase {
    private IAutomationRuleRepository repo;

    this(IAutomationRuleRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createAutomationRule(CreateAutomationRuleRequest r) {
        auto err = SituationEvaluator.validate(r.tenantId, r.automationRuleId.value, r.name);
        if (err.length > 0)
            return UsecaseResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.automationRuleId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Automation rule already exists");

        auto rule = AutomationRule(r.tenantId); //, r.automationRuleId, r.createdBy);
        rule.situationTemplateId = r.situationTemplateId;
        rule.name = r.name;
        rule.description = r.description;
        rule.status = RuleStatus.draft;
        rule.executionOrder = r.executionOrder;
        rule.enabled = true;

        repo.save(rule);
        return UsecaseResult(true, rule.id.value, "");
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

    UsecaseResult updateAutomationRule(UpdateAutomationRuleRequest r) {
        auto rule = repo.findById(r.tenantId, r.automationRuleId);
        if (rule.isNull)
            return UsecaseResult(false, "", "Automation rule not found");

        rule.updatedAt = currentTimestamp();
        rule.name = r.name;
        rule.description = r.description;
        rule.executionOrder = r.executionOrder;
        rule.enabled = r.enabled;

        repo.update(rule);
        return UsecaseResult(true, rule.id.value, "");
    }

    UsecaseResult deleteAutomationRule(TenantId tenantId, AutomationRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return UsecaseResult(false, "", "Automation rule not found");

        repo.remove(rule);
        return UsecaseResult(true, rule.id.value, "");
    }
}
