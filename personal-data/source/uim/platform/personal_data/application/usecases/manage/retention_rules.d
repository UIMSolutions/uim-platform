/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.application.usecases.manage.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class ManageRetentionRulesUseCase { // TODO: UIMUseCase {
    private RetentionRuleRepository repo;

    this(RetentionRuleRepository repo) {
        this.repo = repo;
    }

    CommandResult createRetentionRule(CreateRetentionRuleRequest r) {
        if (r.isNull) return CommandResult(false, "", "ID is required");
        if (r.name.isEmpty) return CommandResult(false, "", "Rule name is required");

        RetentionRule rule;
        rule.id = r.id;
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
        rule.createdAt = clockTime();

        repo.save(rule);
        return CommandResult(true, rule.id.value, "");
    }

    RetentionRule getRetentionRule(TenantId tenantId, RetentionRuleId id) {
        return repo.findById(tenantId, id);
    }

    RetentionRule[] listRetentionRules(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateRetentionRule(UpdateRetentionRuleRequest r) {
        auto existing = repo.findById(r.tenantId, r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Retention rule not found");

        if (r.name.length > 0) existing.name = r.name;
        if (r.description.length > 0) existing.description = r.description;
        if (r.retentionPeriod > 0) existing.retentionPeriod = r.retentionPeriod;
        if (r.periodUnit.length > 0) existing.periodUnit = r.periodUnit.to!RetentionPeriodUnit;
        existing.autoDelete = r.autoDelete;
        existing.notifyBeforeExpiry = r.notifyBeforeExpiry;
        existing.notifyDaysBefore = r.notifyDaysBefore;
        existing.updatedBy = r.updatedBy;
        existing.updatedAt = clockTime();

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteRetentionRule(TenantId tenantId, RetentionRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Retention rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }
}
