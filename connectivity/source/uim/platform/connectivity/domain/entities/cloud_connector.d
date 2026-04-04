/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.cloud_connector;

import uim.platform.connectivity.domain.types;

/// On-premise Cloud Connector registration.
struct CloudConnector {
  ConnectorId id;
  SubaccountId subaccountId;
  TenantId tenantId;
  string locationId; // distinguishes multiple CCs per subaccount
  string description;
  string connectorVersion;
  string host;
  ushort port;
  ConnectorStatus status = ConnectorStatus.disconnected;
  long lastHeartbeat;
  long connectedSince;
  string tunnelEndpoint; // internal tunnel address
  long createdAt;
  long updatedAt;
}
