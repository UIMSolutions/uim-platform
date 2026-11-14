/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.enumerations.connectors;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Connection state of a Cloud Connector.
///
///   connected ⇄ disconnected,  connected ⇄ maintenance,  any → error → connected
enum ConnectorStatus {
  connected,
  disconnected,
  maintenance,
  error,
}

/// Protocol of a service channel.
enum ChannelType {
  http,
  rfc,
  tcp,
}

/// State of a service channel. Only channels of a connected connector can be open.
enum ChannelStatus {
  closed,
  open,
  error,
}
