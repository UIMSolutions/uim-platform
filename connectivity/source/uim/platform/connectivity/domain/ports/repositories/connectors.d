/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.connectors;

// import uim.platform.connectivity.domain.entities.cloud_connector;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Port: outgoing - cloud connector persistence.
interface ConnectorRepository : ITenantRepository!(CloudConnector, ConnectorId) {

  bool existsByLocationId(SubaccountId subaccountId, string locationId);
  CloudConnector findByLocationId(SubaccountId subaccountId, string locationId);
  void removeByLocationId(SubaccountId subaccountId, string locationId);

  size_t countBySubaccount(SubaccountId subaccountId);
  CloudConnector[] findBySubaccount(SubaccountId subaccountId);
  void removeBySubaccount(SubaccountId subaccountId);

}
