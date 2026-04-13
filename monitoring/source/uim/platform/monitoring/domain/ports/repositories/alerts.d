/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.alerts;

// import uim.platform.monitoring.domain.entities.alert;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - alert persistence.
interface AlertRepository {
  Alert findById(AlertId id);
  bool existsById(AlertId id);

  Alert[] findByTenant(TenantId tenantId);
  Alert[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  Alert[] findByState(TenantId tenantId, AlertState state);
  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity);
  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId);
  
  void save(Alert alert);
  void update(Alert alert);
  void remove(AlertId id);
}
