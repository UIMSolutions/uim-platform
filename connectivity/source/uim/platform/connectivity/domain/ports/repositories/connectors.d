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

  bool existsByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId);
  CloudConnector findByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId);
  void removeByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId);

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  CloudConnector[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId);

}
