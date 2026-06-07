/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.application.usecases.manage.data_quality_rules;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class ManageDataQualityRulesUseCase {
    private DataQualityRuleRepository repo;

    this(DataQualityRuleRepository repo) {
        this.repo = repo;
    }

    DataQualityRule getDataQualityRule(TenantId tenantId, DataQualityRuleId id) {
        return repo.findById(tenantId, id);
    }

    DataQualityRule[] listDataQualityRules(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataQualityRule[] listActive(TenantId tenantId) {
        return repo.findActive(tenantId);
    }

    DataQualityRule[] listByFieldName(TenantId tenantId, string fieldName) {
        return repo.findByFieldName(tenantId, fieldName);
    }

    DataQualityRule[] listBySeverity(TenantId tenantId, RuleSeverity severity) {
        return repo.findBySeverity(tenantId, severity);
    }

    CommandResult createDataQualityRule(DataQualityRuleDTO dto) {
        DataQualityRule rule;
        rule.initEntity(dto.tenantId, dto.createdBy);
        rule.id = dto.ruleId;
        rule.name = dto.name;
        rule.description = dto.description;
        rule.fieldName = dto.fieldName;
        rule.fieldPath = dto.fieldPath;
        rule.condition = dto.condition;
        rule.errorMessage = dto.errorMessage;
        rule.bpCategory = dto.bpCategory;
        rule.isActive = dto.isActive;
        rule.weight = dto.weight > 0 ? dto.weight : 10;
        rule.validValues = dto.validValues;
        rule.regexPattern = dto.regexPattern;
        rule.minValue = dto.minValue;
        rule.maxValue = dto.maxValue;

        if (!MasterdataGovernanceValidator.isValidDataQualityRule(rule))
            return CommandResult(false, "", "Invalid data quality rule data");

        repo.save(rule);
        return CommandResult(true, rule.id.value, "");
    }

    CommandResult updateDataQualityRule(DataQualityRuleDTO dto) {
        auto rule = repo.findById(dto.tenantId, dto.ruleId);
        if (rule.isNull)
            return CommandResult(false, "", "Data quality rule not found");

        if (dto.name.length > 0) rule.name = dto.name;
        if (dto.description.length > 0) rule.description = dto.description;
        if (dto.condition.length > 0) rule.condition = dto.condition;
        if (dto.errorMessage.length > 0) rule.errorMessage = dto.errorMessage;
        if (dto.bpCategory.length > 0) rule.bpCategory = dto.bpCategory;
        rule.isActive = dto.isActive;
        if (dto.weight > 0) rule.weight = dto.weight;
        if (dto.validValues.length > 0) rule.validValues = dto.validValues;
        if (dto.regexPattern.length > 0) rule.regexPattern = dto.regexPattern;
        if (dto.minValue.length > 0) rule.minValue = dto.minValue;
        if (dto.maxValue.length > 0) rule.maxValue = dto.maxValue;
        if (!dto.updatedBy.isNull) rule.updatedBy = dto.updatedBy;

        repo.update(rule);
        return CommandResult(true, rule.id.value, "");
    }

    CommandResult deleteDataQualityRule(TenantId tenantId, DataQualityRuleId id) {
        auto rule = repo.findById(tenantId, id);
        if (rule.isNull)
            return CommandResult(false, "", "Data quality rule not found");

        repo.remove(rule);
        return CommandResult(true, rule.id.value, "");
    }
}
