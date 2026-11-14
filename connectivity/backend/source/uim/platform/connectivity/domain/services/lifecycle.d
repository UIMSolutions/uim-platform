/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Allowed status transitions of Cloud Connectors and service channels.
module uim.platform.connectivity.domain.services.lifecycle;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// True if a connector may move from `from` to `target`.
///
///   connected    → disconnected | maintenance | error
///   disconnected → connected | error
///   maintenance  → connected | disconnected
///   error        → connected | disconnected
bool canTransition(ConnectorStatus from, ConnectorStatus target) pure nothrow {
  final switch (from) {
  case ConnectorStatus.connected:
    return target == ConnectorStatus.disconnected || target == ConnectorStatus.maintenance || target == ConnectorStatus.error;
  case ConnectorStatus.disconnected:
    return target == ConnectorStatus.connected || target == ConnectorStatus.error;
  case ConnectorStatus.maintenance:
    return target == ConnectorStatus.connected || target == ConnectorStatus.disconnected;
  case ConnectorStatus.error:
    return target == ConnectorStatus.connected || target == ConnectorStatus.disconnected;
  }
}

/// Move `connector` to `target` or throw a conflict.
void transitionTo(ref CloudConnector connector, ConnectorStatus target) {
  ensureState(canTransition(connector.status, target), "Cloud Connector '" ~ connector.name ~ "' cannot change from '"
      ~ enumText(connector.status) ~ "' to '" ~ enumText(target) ~ "'");
  connector.status = target;
}

/// True if a connected connector missed its heartbeat (policy timeout exceeded).
bool heartbeatOverdue(const CloudConnector c, long now, const MonitoringPolicy policy) pure nothrow {
  if (c.status != ConnectorStatus.connected || policy.heartbeatTimeoutSeconds <= 0)
    return false;
  auto last = c.lastHeartbeatAt > c.connectedAt ? c.lastHeartbeatAt : c.connectedAt;
  return last > 0 && now - last > policy.heartbeatTimeoutSeconds * 10_000_000L;
}

/// A channel can only be opened through a connected connector.
void requireOpenable(const ServiceChannel channel, const CloudConnector connector) {
  ensureState(channel.status != ChannelStatus.open, "Service channel '" ~ channel.name ~ "' is already open");
  ensureState(connector.status == ConnectorStatus.connected, "Cloud Connector '" ~ connector.name
      ~ "' must be connected to open a channel (status: " ~ enumText(connector.status) ~ ")");
}

///
unittest {
  assert(canTransition(ConnectorStatus.connected, ConnectorStatus.maintenance));
  assert(!canTransition(ConnectorStatus.disconnected, ConnectorStatus.maintenance));

  CloudConnector c;
  c.name = "dc1";
  c.connectedAt = 1;
  c.lastHeartbeatAt = 100 * 10_000_000L;
  MonitoringPolicy p;
  p.heartbeatTimeoutSeconds = 60;
  assert(!heartbeatOverdue(c, 150 * 10_000_000L, p));
  assert(heartbeatOverdue(c, 161 * 10_000_000L, p));

  transitionTo(c, ConnectorStatus.disconnected);
  assert(!heartbeatOverdue(c, long.max / 2, p));
  bool conflict;
  try
    transitionTo(c, ConnectorStatus.maintenance);
  catch (ConnectivityConflictException)
    conflict = true;
  assert(conflict);

  ServiceChannel ch;
  conflict = false;
  try
    requireOpenable(ch, c);
  catch (ConnectivityConflictException)
    conflict = true;
  assert(conflict);
}
