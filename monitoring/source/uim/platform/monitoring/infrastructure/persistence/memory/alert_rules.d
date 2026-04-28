/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.alert_rules;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.alert_rule;
// import uim.platform.monitoring.domain.ports.repositories.alert_rules;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryAlertRuleRepository : TenantRepository!(AlertRule, AlertRuleId), AlertRuleRepository {

  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByResource(tenantId, resourceId).length;
  }
  AlertRule[] filterByResource(AlertRule[] rules, MonitoredResourceId resourceId) {
    return rules.filter!(e => e.resourceId == resourceId).array;
  }
  AlertRule[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return filterByResource(findByTenant(tenantId), resourceId);
  }
  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    findByResource(tenantId, resourceId).each!(e => remove(e));
  }

  size_t countByMetric(TenantId tenantId, string metricName) {
    return findByMetric(tenantId, metricName).length;
  }
  AlertRule[] filterByMetric(AlertRule[] rules, string metricName) {
    return rules.filter!(e => e.metricName == metricName).array;
  }
  AlertRule[] findByMetric(TenantId tenantId, string metricName) {
    return filterByMetric(findByTenant(tenantId), metricName);
  }
  void removeByMetric(TenantId tenantId, string metricName) {
    findByMetric(tenantId, metricName).each!(e => remove(e));
  }

  size_t countEnabled(TenantId tenantId) {
    return findEnabled(tenantId).length;
  }
  AlertRule[] filterEnabled(AlertRule[] rules) {
    return rules.filter!(e => e.isEnabled).array;
  }
  AlertRule[] findEnabled(TenantId tenantId) {
    return filterEnabled(findByTenant(tenantId));
  }
  void removeEnabled(TenantId tenantId) {
    findEnabled(tenantId).each!(e => remove(e));
  }

}
