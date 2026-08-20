/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.rule_sets;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageRuleSetsUseCase { 

  UsecaseResult createRuleSet(CreateRuleSetRequest req);
  RuleSet getRuleSet(TenantId tenantId, RuleSetId id);
  RuleSet[] listRuleSets(TenantId tenantId);
  RuleSet[] listByBusinessContext(TenantId tenantId, BusinessContextId contextId);
  UsecaseResult updateRuleSet(UpdateRuleSetRequest req);
  UsecaseResult activateRuleSet(TenantId tenantId, RuleSetId id);
  UsecaseResult deleteRuleSet(TenantId tenantId, RuleSetId id);
  
}
