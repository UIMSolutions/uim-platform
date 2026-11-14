/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.services.cascade;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Keeps the objects that hang off a Cloud Connector consistent with it.
class ConnectorCascade {
  protected ConnectivityRepositories repos;
  protected EventRecorder events;

  this(ConnectivityRepositories repos, EventRecorder events) {
    this.repos = repos;
    this.events = events;
  }

  /// Close every open channel of a connector (it went away). Returns the number closed.
  size_t closeChannels(const CloudConnector connector, string reason, UserId actor = UserId.init) {
    ServiceChannel[] closed;
    auto now = nowStdTime();
    foreach (ch; repos.channels.findByConnector(connector.tenantId, connector.id)) {
      if (ch.status != ChannelStatus.open)
        continue;
      ch.status = ChannelStatus.closed;
      ch.closedAt = now;
      ch.statusMessage = reason;
      ch.update(actor);
      closed ~= ch;
      events.log(ch.tenantId, ConnectivityEventType.channelClosed, SourceType.serviceChannel,
        ch.id.value, ch.name, reason, ch.backendHost, ch.backendPort, actor);
    }
    if (closed.length > 0)
      repos.channels.update(closed);
    return closed.length;
  }

  /// Remove the channels and access rules of an unregistered connector.
  size_t clear(TenantId tenantId, ConnectorId connectorId) {
    auto channels = repos.channels.findByConnector(tenantId, connectorId);
    auto rules = repos.accessRules.findByConnector(tenantId, connectorId);
    if (channels.length > 0)
      repos.channels.remove(channels);
    if (rules.length > 0)
      repos.accessRules.remove(rules);
    return channels.length + rules.length;
  }
}
