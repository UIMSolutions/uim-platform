/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.alert_rules;
// import uim.platform.logging.domain.entities.alert_rule;
// import uim.platform.logging.domain.ports.repositories.alert_rules;

import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryAlertRuleRepository : TenantRepository!(AlertRule, AlertRuleId), AlertRuleRepository {

  size_t countEnabled(TenantId tenantId) {
    return findEnabled(tenantId).length;
  }

  AlertRule[] filterEnabled(AlertRule[] rules) {
    return rules.filter!(entity => entity.isEnabled).array;
  }

  AlertRule[] findEnabled(TenantId tenantId) {
    return filterEnabled(findByTenant(tenantId));
  }

  void removeEnabled(TenantId tenantId) {
    findEnabled(tenantId).each!(entity => remove(entity));
  }

}
