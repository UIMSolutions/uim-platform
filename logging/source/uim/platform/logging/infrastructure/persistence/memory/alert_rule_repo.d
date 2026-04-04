/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.alert_rule_repo;

import uim.platform.logging.domain.entities.alert_rule;
import uim.platform.logging.domain.ports.repositories.alert_rules;
import uim.platform.logging.domain.types;

class MemoryAlertRuleRepository : AlertRuleRepository {
  private AlertRule[AlertRuleId] store;

  AlertRule findById(AlertRuleId id) {
    if (auto p = id in store)
      return *p;
    return AlertRule.init;
  }

  AlertRule[] findByTenant(TenantId tenantId) {
    AlertRule[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId)
        result ~= r;
    return result;
  }

  AlertRule[] findEnabled(TenantId tenantId) {
    AlertRule[] result;
    foreach (ref r; store)
      if (r.tenantId == tenantId && r.isEnabled)
        result ~= r;
    return result;
  }

  void save(AlertRule rule) {
    store[rule.id] = rule;
  }

  void update(AlertRule rule) {
    store[rule.id] = rule;
  }

  void remove(AlertRuleId id) {
    store.remove(id);
  }
}
