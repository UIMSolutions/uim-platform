/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.usecases.connectors;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Register Cloud Connectors and track their connection. `create` registers a
/// connector (connected); `remove` unregisters it together with its channels and rules.
interface IManageConnectorsUseCase : IManageResource!(CloudConnector, ConnectorId,
    RegisterConnectorRequest, UpdateConnectorRequest) {
  /// Alive signal; reconnects a disconnected / failed connector.
  UsecaseResult heartbeat(TenantId tenantId, ConnectorId id, string connectorVersion, UserId actor);
  /// Disconnect; open channels are closed.
  UsecaseResult disconnect(TenantId tenantId, ConnectorId id, UserId actor);
  /// Connect again (from disconnected, maintenance or error).
  UsecaseResult reconnect(TenantId tenantId, ConnectorId id, UserId actor);
  /// Put the connector into maintenance; open channels are closed.
  UsecaseResult startMaintenance(TenantId tenantId, ConnectorId id, UserId actor);
}
