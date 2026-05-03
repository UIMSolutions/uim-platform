/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.channels;

// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.service_channel;
// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.ports.repositories.channels;
// import uim.platform.connectivity.domain.ports.repositories.connectors;
// import uim.platform.connectivity.domain.ports.repositories.connectivity_logs;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for service channel lifecycle.
class ManageChannelsUseCase { // TODO: UIMUseCase {
  private ChannelRepository channels;
  private ConnectorRepository connectorRepo;
  private ConnectivityLogRepository logRepo;

  this(ChannelRepository channels, ConnectorRepository connectorRepo,
      ConnectivityLogRepository logRepo) {
    this.channels = channels;
    this.connectorRepo = connectorRepo;
    this.logRepo = logRepo;
  }

  CommandResult createChannel(CreateChannelRequest req) {
    // Validate connector exists
    auto cc = connectorRepo.findById(req.connectorId);
    if (cc.isNull)
      return CommandResult(false, "", "Connector not found");

    if (req.name.length == 0)
      return CommandResult(false, "", "Channel name is required");
    if (req.virtualHost.length == 0)
      return CommandResult(false, "", "Virtual host is required");
    if (req.backendHost.length == 0)
      return CommandResult(false, "", "Backend host is required");

    // import std.uuid : randomUUID;

    ServiceChannel ch;
    ch.id = randomUUID();
    ch.connectorId = req.connectorId;
    ch.tenantId = req.tenantId;
    ch.name = req.name;
    ch.channelType = req.channelType.to!ChannelType;
    ch.status = ChannelStatus.closed;
    ch.virtualHost = req.virtualHost;
    ch.virtualPort = req.virtualPort;
    ch.backendHost = req.backendHost;
    ch.backendPort = req.backendPort;

    channels.save(ch);
    return CommandResult(true, ch.id.value, "");
  }

  CommandResult openChannel(ChannelId id) {
    auto ch = channels.findById(id);
    if (ch.isNull)
      return CommandResult(false, "", "Channel not found");

    // Verify connector is connected
    auto cc = connectorRepo.findById(ch.connectorId);
    if (cc.isNull)
      return CommandResult(false, "", "Associated connector not found");
    if (cc.status != ConnectorStatus.connected)
      return CommandResult(false, "", "Connector is not connected");

    ch.status = ChannelStatus.open;
    channels.update(ch);

    recordLog(ch.tenantId, ConnectivityEventType.channelOpened, id.value,
        "ServiceChannel", "Channel opened: " ~ ch.name);

    return CommandResult(true, id.value, "");
  }

  CommandResult closeChannel(ChannelId id) {
    auto channel = channels.findById(id);
    if (channel.isNull)
      return CommandResult(false, "", "Channel not found");

    channel.status = ChannelStatus.closed;
    channels.update(channel);

    recordLog(channel.tenantId, ConnectivityEventType.channelClosed, id.value,
        "ServiceChannel", "Channel closed: " ~ channel.name);

    return CommandResult(true, id.value, "");
  }

  ServiceChannel getChannel(ChannelId id) {
    return channels.findById(id);
  }

  ServiceChannel[] listByConnector(ConnectorId connectorId) {
    return channels.findByConnector(connectorId);
  }

  ServiceChannel[] listByTenant(TenantId tenantId) {
    return channels.findByTenant(tenantId);
  }

  CommandResult deleteChannel(ChannelId id) {
    auto channel = channels.findById(id);
    if (channel.isNull)
      return CommandResult(false, "", "Channel not found");

    channels.removeById(id);
    return CommandResult(true, id.value, "");
  }

  private void recordLog(TenantId tenantId, ConnectivityEventType evtType,
      string sourceId, string sourceType, string message) {

    ConnectivityLog entry;
    entry.id = randomUUID();
    entry.tenantId = tenantId;
    entry.eventType = evtType;
    entry.severity = LogSeverity.info;
    entry.sourceId = sourceId;
    entry.sourceType = sourceType;
    entry.message = message;
    logRepo.save(entry);
  }
}

