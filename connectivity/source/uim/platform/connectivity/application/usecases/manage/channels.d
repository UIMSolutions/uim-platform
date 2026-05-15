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
    auto cc = connectorRepo.findById(req.tenantId, req.connectorId);
    if (cc.isNull)
      return CommandResult(false, "", "Connector not found");

    if (req.name.length == 0)
      return CommandResult(false, "", "Channel name is required");
    if (req.virtualHost.length == 0)
      return CommandResult(false, "", "Virtual host is required");
    if (req.backendHost.length == 0)
      return CommandResult(false, "", "Backend host is required");

    ServiceChannel ch;
    ch.initEntity(req.tenantId);

    ch.connectorId = req.connectorId;
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

  CommandResult openChannel(TenantId tenantId, ChannelId id) {
    auto channel = channels.findById(tenantId, id);
    if (channel.isNull)
      return CommandResult(false, "", "Channel not found");

    // Verify connector is connected
    auto connector = connectorRepo.findById(channel.tenantId, channel.connectorId);
    if (connector.isNull)
      return CommandResult(false, "", "Associated connector not found");
    if (connector.status != ConnectorStatus.connected)
      return CommandResult(false, "", "Connector is not connected");

    channel.status = ChannelStatus.open;
    channels.update(channel);

    recordLog(channel.tenantId, ConnectivityEventType.channelOpened, id.value,
        "ServiceChannel", "Channel opened: " ~ channel.name);

    return CommandResult(true, channel.id.value, "");
  }

  CommandResult closeChannel(TenantId tenantId, ChannelId id) {
    auto channel = channels.findById(tenantId, id);
    if (channel.isNull)
      return CommandResult(false, "", "Channel not found");

    channel.status = ChannelStatus.closed;
    channels.update(channel);

    recordLog(channel.tenantId, ConnectivityEventType.channelClosed, id.value,
        "ServiceChannel", "Channel closed: " ~ channel.name);

    return CommandResult(true, channel.id.value, "");
  }

  ServiceChannel getChannel(TenantId tenantId, ChannelId id) {
    return channels.findById(tenantId, id);
  }

  ServiceChannel[] listByConnector(TenantId tenantId, ConnectorId connectorId) {
    return channels.findByConnector(tenantId, connectorId);
  }

  ServiceChannel[] listByTenant(TenantId tenantId) {
    return channels.findByTenant(tenantId);
  }

  CommandResult deleteChannel(TenantId tenantId, ChannelId id) {
    auto channel = channels.findById(tenantId, id);
    if (channel.isNull)
      return CommandResult(false, "", "Channel not found");

    channels.remove(channel);
    return CommandResult(true, channel.id.value, "");
  }

  private void recordLog(TenantId tenantId, ConnectivityEventType evtType,
      string sourceId, string sourceType, string message) {

    ConnectivityLog entry;
    entry.initEntity(tenantId);

    entry.eventType = evtType;
    entry.severity = LogSeverity.info;
    entry.sourceId = sourceId;
    entry.sourceType = sourceType;
    entry.message = message;
    
    logRepo.save(entry);
  }
}

