/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.alert_rules;

// import uim.platform.monitoring.domain.entities.alert_rule;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - alert rule persistence.
interface AlertRuleRepository {
  AlertRule findById(AlertRuleId id);
  AlertRule[] findByTenant(TenantId tenantId);
  AlertRule[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  AlertRule[] findByMetric(TenantId tenantId, string metricName);
  AlertRule[] findEnabled(TenantId tenantId);
  void save(AlertRule rule);
  void update(AlertRule rule);
  void remove(AlertRuleId id);
}
