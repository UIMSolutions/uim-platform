/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.access_rules;
// import uim.platform.connectivity.domain.entities.access_rule;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
/// Port: outgoing - access rule persistence.
interface AccessRuleRepository : ITentRepository!(AccessRule, RuleId) {
  
  size_t countByConnector(TenantId tenantId, ConnectorId connectorId);
  AccessRule[] findByConnector(TenantId tenantId, ConnectorId connectorId);
  void removeByConnector(TenantId tenantId, ConnectorId connectorId);

}
