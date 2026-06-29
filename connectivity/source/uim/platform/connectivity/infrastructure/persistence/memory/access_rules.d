/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.persistence.memory.access_rules;
// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.access_rule;
// import uim.platform.connectivity.domain.ports.repositories.access_rules;

import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
class MemoryAccessRuleRepository : TenantRepository!(AccessRule, RuleId), AccessRuleRepository {

  size_t countByConnector(TenantId tenantId, ConnectorId connectorId) {
    return findByConnector(tenantId, connectorId).length;
  }

  AccessRule[] findByConnector(TenantId tenantId, ConnectorId connectorId) {
    return findByTenant(tenantId).filter!(e => e.connectorId == connectorId).array;
  }

  void removeByConnector(TenantId tenantId, ConnectorId connectorId) {
    findByConnector(tenantId, connectorId).each!(e => remove(e));
  }

}
