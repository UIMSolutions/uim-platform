/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.alerts;

// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface AlertRepository : ITenantRepository!(Alert, AlertId) {

  size_t countByState(TenantId tenantId, AlertState state);
  Alert[] findByState(TenantId tenantId, AlertState state);
  void removeByState(TenantId tenantId, AlertState state);

  size_t countBySeverity(TenantId tenantId, AlertSeverity severity);
  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity);
  void removeBySeverity(TenantId tenantId, AlertSeverity severity);

  size_t countByRule(TenantId tenantId, AlertRuleId ruleId);
  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId);
  void removeByRule(TenantId tenantId, AlertRuleId ruleId);

}
