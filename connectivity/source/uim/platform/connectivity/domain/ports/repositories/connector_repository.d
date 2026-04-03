/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.connector_repository;

import uim.platform.connectivity.domain.entities.cloud_connector;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - cloud connector persistence.
interface ConnectorRepository
{
  CloudConnector findById(ConnectorId id);
  CloudConnector findByLocationId(SubaccountId subaccountId, string locationId);
  CloudConnector[] findBySubaccount(SubaccountId subaccountId);
  CloudConnector[] findByTenant(TenantId tenantId);
  void save(CloudConnector connector);
  void update(CloudConnector connector);
  void remove(ConnectorId id);
}
