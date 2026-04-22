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
interface AlertRuleRepository : ITenantRepository!(AlertRule, AlertRuleId) {

  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId);
  AlertRule[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId);

  size_t countByMetric(TenantId tenantId, string metricName);
  AlertRule[] findByMetric(TenantId tenantId, string metricName);
  void removeByMetric(TenantId tenantId, string metricName);

  size_t countEnabled(TenantId tenantId);
  AlertRule[] findEnabled(TenantId tenantId);
  void removeEnabled(TenantId tenantId);
  
}
