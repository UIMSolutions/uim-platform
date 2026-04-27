/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.alerts;

// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.ports.repositories.alerts;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryAlertRepository :TenantRepository!(Alert, AlertId), AlertRepository {

  Alert[] findByTenant(TenantId tenantId) {
        return store.byValue.filter!(a => a.tenantId == tenantId).array;
  }

  size_t countByState(TenantId tenantId, AlertState state) {
    return findByState(tenantId, state).length;
  }
  Alert[] filterByState(Alert[] alerts, AlertState state) {
    return alerts.filter!(a => a.state == state).array;
  }
  Alert[] findByState(TenantId tenantId, AlertState state) {
    return filterByState(findByTenant(tenantId), state);
  }
  void removeByState(TenantId tenantId, AlertState state) {
    findByState(tenantId, state).each!(a => remove(a));
  }

  size_t countBySeverity(TenantId tenantId, AlertSeverity severity) {
    return findBySeverity(tenantId, severity).length;
  }
  Alert[] filterBySeverity(Alert[] alerts, AlertSeverity severity) {
    return alerts.filter!(a => a.severity == severity).array;
  }
  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity) {
    return findByTenant(tenantId).filter!(a => a.severity == severity).array;
  }
  void removeBySeverity(TenantId tenantId, AlertSeverity severity) {
    findBySeverity(tenantId, severity).each!(a => remove(a));
  }

  size_t countByRule(TenantId tenantId, AlertRuleId ruleId) {
    return findByRule(tenantId, ruleId).length;
  }
  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId) {
    return findByTenant(tenantId).filter!(a => a.ruleId == ruleId).array;
  }

  void save(Alert a) {
    store[a.id] = a;
  }

  void update(Alert a) {
    store[a.id] = a;
  }

  void remove(AlertId id) {
    store.remove(id);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  size_t countByState(TenantId tenantId, AlertState state) {
    return findByState(tenantId, state).length;
  }
}
