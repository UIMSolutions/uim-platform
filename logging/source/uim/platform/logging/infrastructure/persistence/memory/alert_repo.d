/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.alert;

// import uim.platform.logging.domain.entities.alert;
// import uim.platform.logging.domain.ports.repositories.alerts;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryAlertRepository : AlertRepository {
  private Alert[AlertId] store;

  Alert findById(AlertId id) {
    if (auto p = id in store)
      return *p;
    return Alert.init;
  }

  Alert[] findByTenant(TenantId tenantId) {
    Alert[] result;
    foreach (ref a; store)
      if (a.tenantId == tenantId)
        result ~= a;
    return result;
  }

  Alert[] findByState(TenantId tenantId, AlertState state) {
    Alert[] result;
    foreach (ref a; store)
      if (a.tenantId == tenantId && a.state == state)
        result ~= a;
    return result;
  }

  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity) {
    Alert[] result;
    foreach (ref a; store)
      if (a.tenantId == tenantId && a.severity == severity)
        result ~= a;
    return result;
  }

  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId) {
    Alert[] result;
    foreach (ref a; store)
      if (a.tenantId == tenantId && a.ruleId == ruleId)
        result ~= a;
    return result;
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
    size_t count;
    foreach (ref a; store)
      if (a.tenantId == tenantId)
        count++;
    return count;
  }

  size_t countByState(TenantId tenantId, AlertState state) {
    size_t count;
    foreach (ref a; store)
      if (a.tenantId == tenantId && a.state == state)
        count++;
    return count;
  }
}
