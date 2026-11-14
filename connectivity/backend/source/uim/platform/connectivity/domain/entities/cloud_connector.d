/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.cloud_connector;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// A Cloud Connector registered for a subaccount — the on-premise end of the
/// secure tunnel. Identified per subaccount by its location ID.
struct CloudConnector {
  mixin TenantEntity!ConnectorId;

  SubaccountId subaccountId;
  string name; /// display name, unique per tenant
  string locationId; /// "" = default location; unique per subaccount
  string description;
  string connectorVersion;
  string host; /// on-premise host of the connector
  int port = 8443;
  string tunnelEndpoint; /// cloud side tunnel address

  ConnectorStatus status = ConnectorStatus.connected;
  string statusMessage;
  long connectedAt;
  long lastHeartbeatAt;
}
