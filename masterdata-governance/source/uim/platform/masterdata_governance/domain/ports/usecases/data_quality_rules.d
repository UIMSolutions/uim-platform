/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.ports.usecases.data_quality_rules;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

interface IManageDataQualityRulesUseCase {

    DataQualityRule getDataQualityRule(TenantId tenantId, DataQualityRuleId id);
    DataQualityRule[] listDataQualityRules(TenantId tenantId);
    DataQualityRule[] listActive(TenantId tenantId);
    DataQualityRule[] listDataQualityRules(TenantId tenantId, string fieldName);
    DataQualityRule[] listDataQualityRules(TenantId tenantId, RuleSeverity severity);
    UsecaseResult createDataQualityRule(DataQualityRuleDTO dto);
    UsecaseResult updateDataQualityRule(DataQualityRuleDTO dto);
    UsecaseResult deleteDataQualityRule(TenantId tenantId, DataQualityRuleId id);
    
}
