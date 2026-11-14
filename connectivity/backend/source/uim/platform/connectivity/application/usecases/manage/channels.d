/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.channels;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: service channels. Names and virtual endpoints are unique per
/// connector; only closed channels can be re-mapped or deleted.
class ManageChannelsUseCase
  : ResourceUseCase!(ServiceChannel, ChannelId, CreateChannelRequest, UpdateChannelRequest),
  IManageChannelsUseCase {

  this(ConnectivityRepositories repos, EventRecorder events) {
    super(repos, repos.channels, events, "Service channel", "connectivity.channel");
  }

  override protected ServiceChannel build(CreateChannelRequest r) {
    auto connector = requireConnector(r.tenantId, r.parentId);
    auto ch = ServiceChannel(r.tenantId);
    ch.connectorId = connector.id;
    ch.connectorName = connector.name;
    assignMatching(ch, r.spec);
    check(ch);
    return ch;
  }

  override protected void apply(ref ServiceChannel ch, ChannelSpec spec) {
    auto before = mappingOf(ch);
    assignMatching(ch, spec);
    if (mappingOf(ch) != before)
      ensureState(ch.status != ChannelStatus.open, "Close service channel '" ~ ch.name ~ "' before changing its mapping");
    check(ch);
  }

  protected static string mappingOf(const ServiceChannel ch) {
    return format("%s|%s:%d|%s:%d|%d", enumText(ch.channelType), ch.virtualHost, ch.virtualPort,
      ch.backendHost, ch.backendPort, ch.connectionCount);
  }

  protected void check(ref ServiceChannel ch) {
    ch.name = ch.name.strip;
    ch.virtualHost = ch.virtualHost.strip.toLower;
    ch.backendHost = ch.backendHost.strip;
    validateDisplayName("Service channel", ch.name);
    validateHost("Virtual host", ch.virtualHost);
    validatePort("Virtual port", ch.virtualPort);
    validateHost("Back-end host", ch.backendHost);
    validatePort("Back-end port", ch.backendPort);
    validate(ch.connectionCount >= 1 && ch.connectionCount <= 20, "Connection count must be between 1 and 20");
    ensureUnique(repos.channels.findByName(ch.tenantId, ch.connectorId, ch.name), ch,
      "Cloud Connector '" ~ ch.connectorName ~ "'");
    foreach (other; repos.channels.findByConnector(ch.tenantId, ch.connectorId))
      ensureState(other.id == ch.id || other.virtualHost != ch.virtualHost || other.virtualPort != ch.virtualPort,
        "Virtual endpoint " ~ ch.virtualHost ~ ":" ~ ch.virtualPort.to!string ~ " is already used by channel '"
          ~ other.name ~ "'");
  }

  override protected void beforeRemove(ServiceChannel ch) {
    ensureState(ch.status != ChannelStatus.open, "Close service channel '" ~ ch.name ~ "' before deleting it");
  }

  UsecaseResult open(TenantId tenantId, ChannelId id, UserId actor) {
    return transition(tenantId, id, actor, "opened", (ref ServiceChannel ch) {
      auto connector = requireConnector(ch.tenantId, ch.connectorId);
      requireOpenable(ch, connector);
      ch.status = ChannelStatus.open;
      ch.openedAt = nowStdTime();
      ch.statusMessage = "";
      events.log(ch.tenantId, ConnectivityEventType.channelOpened, SourceType.serviceChannel, ch.id.value, ch.name,
        "Channel opened: " ~ ch.virtualHost ~ ":" ~ ch.virtualPort.to!string ~ " → " ~ ch.backendHost ~ ":"
          ~ ch.backendPort.to!string, ch.backendHost, ch.backendPort, actor);
    });
  }

  UsecaseResult close(TenantId tenantId, ChannelId id, UserId actor) {
    return transition(tenantId, id, actor, "closed", (ref ServiceChannel ch) {
      ensureState(ch.status != ChannelStatus.closed, "Service channel '" ~ ch.name ~ "' is already closed");
      ch.status = ChannelStatus.closed;
      ch.closedAt = nowStdTime();
      ch.statusMessage = "Closed";
      events.log(ch.tenantId, ConnectivityEventType.channelClosed, SourceType.serviceChannel, ch.id.value, ch.name,
        "Channel closed", ch.backendHost, ch.backendPort, actor);
    });
  }
}
