/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.retention_rules;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageRetentionRulesUseCase { 
    
    UsecaseResult createRetentionRule(CreateRetentionRuleRequest req);
    UsecaseResult updateRetentionRule(UpdateRetentionRuleRequest req);
    bool hasRetentionRule(TenantId tenantId, RetentionRuleId id);
    RetentionRule getRetentionRule(TenantId tenantId, RetentionRuleId id);
    RetentionRule[] listRetentionRules(TenantId tenantId);
    UsecaseResult deleteRetentionRule(TenantId tenantId, RetentionRuleId id);

}
