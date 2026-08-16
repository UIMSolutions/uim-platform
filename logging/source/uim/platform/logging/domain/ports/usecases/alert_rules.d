/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.usecases.alert_rules;
// import uim.platform.logging.domain.entities.alert_rule;
// import uim.platform.logging.domain.ports.repositories.alert_rules;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IManageAlertRulesUseCase { 

  CommandResult createAlertRule(CreateAlertRuleRequest req);

  CommandResult updateAlertRule(UpdateAlertRuleRequest req);

  bool hasRule(TenantId tenantId, AlertRuleId id);

  AlertRule getRule(TenantId tenantId, AlertRuleId ruleId);

  AlertRule[] listRules(TenantId tenantId);

  AlertRule[] listEnabledRules(TenantId tenantId);

  CommandResult deleteAlertRule(TenantId tenantId, AlertRuleId id);

}
