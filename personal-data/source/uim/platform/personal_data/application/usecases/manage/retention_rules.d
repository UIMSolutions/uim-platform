/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageRetentionRulesUseCase {
    private IRetentionRuleRepository repo;

    this(IRetentionRuleRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createRetentionRule(CreateRetentionRuleRequest r) {
        if (r.ruleId.isNull) return UsecaseResult(false, "", "ID is required");
        if (r.name.isEmpty) return UsecaseResult(false, "", "Rule name is required");

        RetentionRule rule;
        rule.id = r.ruleId;
        rule.tenantId = r.tenantId;
        rule.name = r.name;
        rule.description = r.description;
        rule.status = RetentionRuleStatus.active;
        rule.retentionPeriod = r.retentionPeriod;
        rule.periodUnit = r.periodUnit.length > 0 ? r.periodUnit.to!RetentionPeriodUnit : RetentionPeriodUnit.years;
        rule.dataCategoryIds = r.dataCategoryIds;
        rule.applicationIds = r.applicationIds;
        rule.purposeIds = r.purposeIds;
        rule.autoDelete = r.autoDelete;
        rule.notifyBeforeExpiry = r.notifyBeforeExpiry;
        rule.notifyDaysBefore = r.notifyDaysBefore;
        rule.createdBy = r.createdBy;
        rule.createdAt = currentTimestamp();

        repo.save(rule);
        return UsecaseResult(true, rule.id.value, "");
    }

    RetentionRule getRetentionRule(TenantId tenantId, RetentionRuleId id) {
        return repo.findById(tenantId, id);
    }

    RetentionRule[] listRetentionRules(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateRetentionRule(UpdateRetentionRuleRequest r) {
        auto existing = repo.findById(r.tenantId, r.ruleId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Retention rule not found");

        if (r.name.length > 0) existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.retentionPeriod > 0) existing.retentionPeriod = r.retentionPeriod;
        if (r.periodUnit.length > 0) existing.periodUnit = r.periodUnit.to!RetentionPeriodUnit;
        existing.autoDelete = r.autoDelete;
        existing.notifyBeforeExpiry = r.notifyBeforeExpiry;
        existing.notifyDaysBefore = r.notifyDaysBefore;
        existing.updatedBy = r.updatedBy;
        existing.updatedAt = currentTimestamp();

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteRetentionRule(TenantId tenantId, RetentionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return UsecaseResult(false, "", "Retention rule not found");

        repo.remove(rule);
        return UsecaseResult(true, rule.id.value, "");
    }
}
