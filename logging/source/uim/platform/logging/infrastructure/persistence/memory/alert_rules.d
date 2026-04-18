/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.alert_rules;

// import uim.platform.logging.domain.entities.alert_rule;
// import uim.platform.logging.domain.ports.repositories.alert_rules;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryAlertRuleRepository : AlertRuleRepository {
  private AlertRule[AlertRuleId] store;

  bool existsById(AlertRuleId id) {
    return (id in store) ? true : false;
  }

  AlertRule findById(AlertRuleId id) {
    return (existsById(id)) ? store[id] : AlertRule.init;
  }

  AlertRule[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(r => r.tenantId == tenantId).array;
  }

  AlertRule[] findEnabled(TenantId tenantId) {
    return findByTenant(tenantId).filter!(r => r.isEnabled).array;
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
