/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.retention_rules;

// import uim.platform.data_privacy.domain.entities.retention_rule;
// import uim.platform.data_privacy.domain.ports.repositories.retention_rules;
// import uim.platform.data_privacy.application.dto;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface ManageRetentionRulesUseCase { 

  UsecaseResult createRule(CreateRetentionRuleRequest req);
  RetentionRule getRule(TenantId tenantId, RetentionRuleId id);
  RetentionRule[] listRules(TenantId tenantId);
  RetentionRule[] listRules(TenantId tenantId, ProcessingPurpose purpose);
  UsecaseResult updateRule(UpdateRetentionRuleRequest req);
  UsecaseResult deleteRule(TenantId tenantId, RetentionRuleId id);

}
