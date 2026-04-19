/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.automation_rules;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageAutomationRulesUseCase { // TODO: UIMUseCase {
    private AutomationRuleRepository repo;

    this(AutomationRuleRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateAutomationRuleRequest r) {
        auto err = SituationEvaluator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Automation rule already exists");

        AutomationRule rule;
        rule.id = r.id;
        rule.templateId = r.templateId;
        rule.tenantId = r.tenantId;
        rule.name = r.name;
        rule.description = r.description;
        rule.status = RuleStatus.draft;
        rule.executionOrder = r.executionOrder;
        rule.enabled = true;
        rule.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        rule.createdAt = now;
        rule.modifiedAt = now;

        repo.save(rule);
        return CommandResult(true, rule.id, "");
    }

    AutomationRule getById(AutomationRuleId id) {
        return repo.findById(id);
    }

    AutomationRule[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AutomationRule[] listByTemplate(SituationTemplateId templateId) {
        return repo.findByTemplate(templateId);
    }

    AutomationRule[] listActive(TenantId tenantId) {
        return repo.findActive(tenantId);
    }

    CommandResult update(UpdateAutomationRuleRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Automation rule not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.executionOrder = r.executionOrder;
        existing.enabled = r.enabled;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(AutomationRuleId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Automation rule not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
