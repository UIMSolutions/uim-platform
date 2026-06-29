/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.persistence.memory.data_quality_rules;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

class MemoryDataQualityRuleRepository
    : TenantRepository!(DataQualityRule, DataQualityRuleId), DataQualityRuleRepository {

    DataQualityRule[] findByFieldName(TenantId tenantId, string fieldName) {
        return findByTenant(tenantId).filter!(e => e.fieldName == fieldName).array;
    }

    DataQualityRule[] findByRuleType(TenantId tenantId, RuleType ruleType) {
        return findByTenant(tenantId).filter!(e => e.ruleType == ruleType).array;
    }

    DataQualityRule[] findBySeverity(TenantId tenantId, RuleSeverity severity) {
        return findByTenant(tenantId).filter!(e => e.severity == severity).array;
    }

    DataQualityRule[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(e => e.isActive).array;
    }

    DataQualityRule[] findByBpCategory(TenantId tenantId, string bpCategory) {
        return findByTenant(tenantId).filter!(e => e.bpCategory == bpCategory || e.bpCategory == "all").array;
    }

    void removeByRuleType(TenantId tenantId, RuleType ruleType) {
        findByRuleType(tenantId, ruleType).each!(e => remove(e));
    }
}
