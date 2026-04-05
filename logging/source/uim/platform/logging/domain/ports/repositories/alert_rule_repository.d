/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.alert_rules;

import uim.platform.logging.domain.entities.alert_rule;
import uim.platform.logging.domain.types;

interface AlertRuleRepository {
  AlertRule findById(AlertRuleId id);
  AlertRule[] findByTenant(TenantId tenantId);
  AlertRule[] findEnabled(TenantId tenantId);
  void save(AlertRule rule);
  void update(AlertRule rule);
  void remove(AlertRuleId id);
}
