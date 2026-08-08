/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.retention_rules;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageRetentionRulesUseCase { 

    CommandResult createRetentionRule(CreateRetentionRuleRequest r);
    RetentionRule getRetentionRule(TenantId tenantId, RetentionRuleId id);
    RetentionRule[] listRetentionRules(TenantId tenantId);
    CommandResult updateRetentionRule(UpdateRetentionRuleRequest r);
    CommandResult deleteRetentionRule(TenantId tenantId, RetentionRuleId id);

}

