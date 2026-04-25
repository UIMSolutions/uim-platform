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

  AlertRule[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  AlertRule[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId).array;
  }

  AlertRule[] findByMetric(TenantId tenantId, string metricName) {
    return findByTenant(tenantId).filter!(e => e.metricName == metricName).array;
  }

  AlertRule[] findEnabled(TenantId tenantId) {
    return findByTenant(tenantId).filter!(e => e.isEnabled).array;
  }

}
