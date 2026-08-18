/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.residence_rules;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageResidenceRulesUseCase { 
    
    UsecaseResult createResidenceRule(CreateResidenceRuleRequest req);
    UsecaseResult updateResidenceRule(UpdateResidenceRuleRequest req);
    bool hasResidenceRule(TenantId tenantId, ResidenceRuleId id);
    ResidenceRule getResidenceRule(TenantId tenantId, ResidenceRuleId id);
    ResidenceRule[] listResidenceRules(TenantId tenantId);
    ResidenceRule[] listResidenceRules(TenantId tenantId, BusinessPurposeId purposeId);
    UsecaseResult deleteResidenceRule(TenantId tenantId, ResidenceRuleId id);

}
