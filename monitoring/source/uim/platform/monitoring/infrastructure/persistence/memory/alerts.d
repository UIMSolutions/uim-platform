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
class MemoryAlertRepository : TenantRepository!(Alert, AlertId), AlertRepository {

  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByResource(tenantId, resourceId).length;
  }

  Alert[] filterByResource(Alert[] alerts, MonitoredResourceId resourceId) {
    return alerts.filter!(e => e.resourceId == resourceId).array;
  }

  Alert[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return filterByResource(findByTenant(tenantId), resourceId);
  }

  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    findByResource(tenantId, resourceId).each!(e => remove(e));
  }

  size_t countByState(TenantId tenantId, AlertState state) {
    return findByState(tenantId, state).length;
  }

  Alert[] filterByState(Alert[] alerts, AlertState state) {
    return alerts.filter!(e => e.state == state).array;
  }

  Alert[] findByState(TenantId tenantId, AlertState state) {
    return filterByState(findByTenant(tenantId), state);
  }

  void removeByState(TenantId tenantId, AlertState state) {
    findByState(tenantId, state).each!(e => remove(e));
  }

  size_t countBySeverity(TenantId tenantId, AlertSeverity severity) {
    return findBySeverity(tenantId, severity).length;
  }

  Alert[] filterBySeverity(Alert[] alerts, AlertSeverity severity) {
    return alerts.filter!(e => e.severity == severity).array;
  }

  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity) {
    return filterBySeverity(findByTenant(tenantId), severity);
  }

  void removeBySeverity(TenantId tenantId, AlertSeverity severity) {
    findBySeverity(tenantId, severity).each!(e => remove(e));
  }

  size_t countByRule(TenantId tenantId, AlertRuleId ruleId) {
    return findByRule(tenantId, ruleId).length;
  }

  Alert[] filterByRule(Alert[] alerts, AlertRuleId ruleId) {
    return alerts.filter!(e => e.ruleId == ruleId).array;
  }

  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId) {
    return filterByRule(findByTenant(tenantId), ruleId);
  }

  void removeByRule(TenantId tenantId, AlertRuleId ruleId) {
    findByRule(tenantId, ruleId).each!(e => remove(e));
  }

}
