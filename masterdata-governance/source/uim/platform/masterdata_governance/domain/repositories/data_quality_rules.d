/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.repositories.data_quality_rules;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

interface DataQualityRuleRepository : ITenantRepository!(DataQualityRule, DataQualityRuleId) {

    DataQualityRule[] findByFieldName(TenantId tenantId, string fieldName);
    DataQualityRule[] findByRuleType(TenantId tenantId, RuleType ruleType);
    DataQualityRule[] findBySeverity(TenantId tenantId, RuleSeverity severity);
    DataQualityRule[] findActive(TenantId tenantId);
    DataQualityRule[] findByBpCategory(TenantId tenantId, string bpCategory);
    void removeByRuleType(TenantId tenantId, RuleType ruleType);
}
