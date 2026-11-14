/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.connectors;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: Cloud Connectors. A location ID is unique per subaccount;
/// unregistering removes the connector's channels and access rules.
class ManageConnectorsUseCase
  : ResourceUseCase!(CloudConnector, ConnectorId, RegisterConnectorRequest, UpdateConnectorRequest),
  IManageConnectorsUseCase {

  protected ConnectorCascade cascade;

  this(ConnectivityRepositories repos, EventRecorder events, ConnectorCascade cascade) {
    super(repos, repos.connectors, events, "Cloud Connector", "connectivity.connector");
    this.cascade = cascade;
  }

  override protected CloudConnector build(RegisterConnectorRequest r) {
    auto c = CloudConnector(r.tenantId);
    assignMatching(c, r.spec);
    c.name = c.name.strip;
    c.locationId = c.locationId.strip;
    check(c);
    ensureUnique(repos.connectors.findByName(r.tenantId, c.name), c, "this tenant");
    auto other = repos.connectors.findByLocation(r.tenantId, c.subaccountId, c.locationId);
    ensureState(other.isNull, "Location ID '" ~ c.locationId ~ "' is already used by Cloud Connector '"
        ~ other.name ~ "' in this subaccount");
    c.status = ConnectorStatus.connected;
    c.connectedAt = c.createdAt;
    c.lastHeartbeatAt = c.createdAt;
    c.statusMessage = "Registered";
    return c;
  }

  /// Subaccount and location identify the tunnel and cannot change.
  override protected void apply(ref CloudConnector c, ConnectorSpec spec) {
    assignMatching(c, spec, ["subaccountId", "locationId"]);
    c.name = c.name.strip;
    check(c);
    ensureUnique(repos.connectors.findByName(c.tenantId, c.name), c, "this tenant");
  }

  protected static void check(const ref CloudConnector c) {
    validateDisplayName("Cloud Connector", c.name);
    validateLocationId(c.locationId);
    validateHost("Cloud Connector host", c.host);
    validatePort("Cloud Connector port", c.port);
  }

  override protected void beforeRemove(CloudConnector c) {
    auto open = repos.channels.findByConnector(c.tenantId, c.id).filter!(ch => ch.status == ChannelStatus.open).array;
    ensureState(open.length == 0, "Cloud Connector '" ~ c.name ~ "' has " ~ open.length.to!string
        ~ " open service channel(s) — close or disconnect first");
  }

  override protected void afterCreate(CloudConnector c, UserId actor) {
    events.log(c.tenantId, ConnectivityEventType.connectionEstablished, SourceType.cloudConnector, c.id.value,
      c.name, "Cloud Connector registered for location '" ~ c.locationId ~ "'", c.host, c.port, actor);
  }

  override protected void afterRemove(CloudConnector c, UserId actor) {
    auto removed = cascade.clear(c.tenantId, c.id);
    events.log(c.tenantId, ConnectivityEventType.connectionLost, SourceType.cloudConnector, c.id.value, c.name,
      "Cloud Connector unregistered (" ~ removed.to!string ~ " channel(s) / rule(s) removed)", c.host, c.port, actor);
  }

  UsecaseResult heartbeat(TenantId tenantId, ConnectorId id, string connectorVersion, UserId actor) {
    return transition(tenantId, id, actor, "heartbeat received", (ref CloudConnector c) {
      auto now = nowStdTime();
      if (c.status == ConnectorStatus.disconnected || c.status == ConnectorStatus.error) {
        transitionTo(c, ConnectorStatus.connected);
        c.connectedAt = now;
        c.statusMessage = "Reconnected by heartbeat";
        events.log(c.tenantId, ConnectivityEventType.connectionEstablished, SourceType.cloudConnector,
          c.id.value, c.name, c.statusMessage, c.host, c.port, actor);
      }
      if (connectorVersion.strip.length > 0)
        c.connectorVersion = connectorVersion.strip;
      c.lastHeartbeatAt = now;
    });
  }

  UsecaseResult disconnect(TenantId tenantId, ConnectorId id, UserId actor) {
    return transition(tenantId, id, actor, "disconnected", (ref CloudConnector c) {
      transitionTo(c, ConnectorStatus.disconnected);
      c.statusMessage = "Disconnected";
      auto closed = cascade.closeChannels(c, "Cloud Connector disconnected", actor);
      events.log(c.tenantId, ConnectivityEventType.connectionLost, SourceType.cloudConnector, c.id.value, c.name,
        "Disconnected (" ~ closed.to!string ~ " channel(s) closed)", c.host, c.port, actor);
    });
  }

  UsecaseResult reconnect(TenantId tenantId, ConnectorId id, UserId actor) {
    return transition(tenantId, id, actor, "connected", (ref CloudConnector c) {
      ensureState(c.status != ConnectorStatus.connected, "Cloud Connector '" ~ c.name ~ "' is already connected");
      transitionTo(c, ConnectorStatus.connected);
      c.connectedAt = nowStdTime();
      c.lastHeartbeatAt = c.connectedAt;
      c.statusMessage = "Connected";
      events.log(c.tenantId, ConnectivityEventType.connectionEstablished, SourceType.cloudConnector,
        c.id.value, c.name, "Connected", c.host, c.port, actor);
    });
  }

  UsecaseResult startMaintenance(TenantId tenantId, ConnectorId id, UserId actor) {
    return transition(tenantId, id, actor, "in maintenance", (ref CloudConnector c) {
      transitionTo(c, ConnectorStatus.maintenance);
      c.statusMessage = "Maintenance";
      auto closed = cascade.closeChannels(c, "Cloud Connector in maintenance", actor);
      events.log(c.tenantId, ConnectivityEventType.maintenanceStarted, SourceType.cloudConnector, c.id.value,
        c.name, "Maintenance started (" ~ closed.to!string ~ " channel(s) closed)", c.host, c.port, actor);
    });
  }
}
