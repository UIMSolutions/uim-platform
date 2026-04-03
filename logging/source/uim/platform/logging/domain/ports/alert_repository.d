/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.alert_repository;

import uim.platform.logging.domain.entities.alert;
import uim.platform.logging.domain.types;

interface AlertRepository {
  Alert findById(AlertId id);
  Alert[] findByTenant(TenantId tenantId);
  Alert[] findByState(TenantId tenantId, AlertState state);
  Alert[] findBySeverity(TenantId tenantId, AlertSeverity severity);
  Alert[] findByRule(TenantId tenantId, AlertRuleId ruleId);
  void save(Alert a);
  void update(Alert a);
  void remove(AlertId id);
  long countByTenant(TenantId tenantId);
  long countByState(TenantId tenantId, AlertState state);
}
