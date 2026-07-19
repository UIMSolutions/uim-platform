/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.responsibility_rules;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ManageResponsibilityRulesUseCase {
    private ResponsibilityRuleRepository repo;

    this(ResponsibilityRuleRepository repo) {
        this.repo = repo;
    }

    ResponsibilityRule getRule(TenantId tenantId, ResponsibilityRuleId id) {
        return repo.findById(tenantId, id);
    }

    ResponsibilityRule[] listRules(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ResponsibilityRule[] listRulesByContext(TenantId tenantId, string contextId) {
        return repo.findByContext(tenantId, contextId);
    }

    CommandResult createRule(ResponsibilityRuleDTO dto) {
        auto r = ResponsibilityRule(dto.tenantId); //, UserId("test-user"));
        r.id = dto.ruleId;
        r.name = dto.name;
        r.description = dto.description;
        r.ruleType = toRuleType(dto.ruleType);
        r.status = toRuleStatus(dto.status);
        r.expression = dto.expression;
        r.priority = dto.priority;
        r.contextId = dto.contextId;
        r.teamId = dto.teamId;

        if (r.name.isEmpty)
            return CommandResult(false, "", "Rule name is required");
        repo.save(r);
        return CommandResult(true, r.id.value, "");
    }

    CommandResult updateRule(ResponsibilityRuleDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.ruleId);
        if (existing.isNull)
            return CommandResult(false, "", "Rule not found");
        if (dto.name.length > 0)
            existing.name = dto.name;
        if (dto.description.length > 0)
            existing.description = dto.description;
        if (dto.expression.length > 0)
            existing.expression = dto.expression;
        if (dto.teamId.length > 0)
            existing.teamId = dto.teamId;
        if (!dto.updatedBy.isNull)
            existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteRule(TenantId tenantId, ResponsibilityRuleId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Rule not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }

    private static RuleStatus parseRuleStatus(string s) {
        

        try {
            return s.to!RuleStatus;
        } catch (Exception) {
            return RuleStatus.active;
        }
    }
}
