/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.service_channel;

import uim.platform.connectivity.domain.types;

/// Tunnel / service channel between cloud and on-premise.
struct ServiceChannel {
  ChannelId id;
  ConnectorId connectorId;
  TenantId tenantId;
  string name;
  ChannelType channelType = ChannelType.http;
  ChannelStatus status = ChannelStatus.closed;

  // Virtual mapping (cloud-side)
  string virtualHost;
  ushort virtualPort;

  // Backend target (on-premise side)
  string backendHost;
  ushort backendPort;

  long openedAt;
  long closedAt;
  long createdAt;
  long updatedAt;
}
