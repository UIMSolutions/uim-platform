/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.access_rules;

import uim.platform.connectivity.domain.entities.access_rule;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - access rule persistence.
interface AccessRuleRepository {
  bool existsId(RuleId id);
  AccessRule findById(RuleId id);
  AccessRule[] findByConnector(ConnectorId connectorId);
  AccessRule[] findByTenant(TenantId tenantId);
  void save(AccessRule rule);
  void update(AccessRule rule);
  void remove(RuleId id);
}
