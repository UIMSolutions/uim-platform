/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.service_channel;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// A service channel: exposes an on-premise back end (backendHost:backendPort)
/// under a virtual host and port on the cloud side of a Cloud Connector.
struct ServiceChannel {
  mixin TenantEntity!ChannelId;

  ConnectorId connectorId;
  string connectorName;
  string name; /// unique per connector
  string description;
  ChannelType channelType = ChannelType.http;

  string virtualHost;
  int virtualPort;
  string backendHost;
  int backendPort;
  int connectionCount = 1; /// parallel tunnel connections

  ChannelStatus status = ChannelStatus.closed;
  string statusMessage;
  long openedAt;
  long closedAt;
}
