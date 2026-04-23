/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.alerts;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.alert;
// import uim.platform.monitoring.domain.ports.repositories.alerts;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryAlertRepository : AlertRepository {
  private Alert[AlertId] store;

  bool existsById(AlertId id) {
    return (id in store) ? true : false;
  }

  Alert findById(AlertId id) {
    return existsById(id) ? store[id] : Alert.init;
  }

  Alert[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  Alert[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId).array;
  }

  Alert[] findByState(TenantId tenantId, AlertState state) {
    return findByTenant(tenantId).filter!(e => e.state == state).array;
  }

  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity) {
    return findByTenant(tenantId).filter!(e => e.severity == severity).array;
  }

  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId) {
    return findByTenant(tenantId).filter!(e => e.ruleId == ruleId).array;
  }

  void save(Alert alert) {
    store[alert.id] = alert;
  }

  void update(Alert alert) {
    store[alert.id] = alert;
  }

  void remove(AlertId id) {
    store.remove(id);
  }
}
