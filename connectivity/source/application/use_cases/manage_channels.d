module application.use_cases.manage_channels;

import application.dto;
import domain.entities.service_channel;
import domain.entities.connectivity_log;
import domain.ports.channel_repository;
import domain.ports.connector_repository;
import domain.ports.connectivity_log_repository;
import domain.types;

/// Application service for service channel lifecycle.
class ManageChannelsUseCase
{
    private ChannelRepository channelRepo;
    private ConnectorRepository connectorRepo;
    private ConnectivityLogRepository logRepo;

    this(ChannelRepository channelRepo, ConnectorRepository connectorRepo,
        ConnectivityLogRepository logRepo)
    {
        this.channelRepo = channelRepo;
        this.connectorRepo = connectorRepo;
        this.logRepo = logRepo;
    }

    CommandResult createChannel(CreateChannelRequest req)
    {
        // Validate connector exists
        auto cc = connectorRepo.findById(req.connectorId);
        if (cc.id.length == 0)
            return CommandResult(false, "", "Connector not found");

        if (req.name.length == 0)
            return CommandResult(false, "", "Channel name is required");
        if (req.virtualHost.length == 0)
            return CommandResult(false, "", "Virtual host is required");
        if (req.backendHost.length == 0)
            return CommandResult(false, "", "Backend host is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        ServiceChannel ch;
        ch.id = id;
        ch.connectorId = req.connectorId;
        ch.tenantId = req.tenantId;
        ch.name = req.name;
        ch.channelType = parseChannelType(req.channelType);
        ch.status = ChannelStatus.closed;
        ch.virtualHost = req.virtualHost;
        ch.virtualPort = req.virtualPort;
        ch.backendHost = req.backendHost;
        ch.backendPort = req.backendPort;

        channelRepo.save(ch);
        return CommandResult(true, id, "");
    }

    CommandResult openChannel(ChannelId id)
    {
        auto ch = channelRepo.findById(id);
        if (ch.id.length == 0)
            return CommandResult(false, "", "Channel not found");

        // Verify connector is connected
        auto cc = connectorRepo.findById(ch.connectorId);
        if (cc.id.length == 0)
            return CommandResult(false, "", "Associated connector not found");
        if (cc.status != ConnectorStatus.connected)
            return CommandResult(false, "", "Connector is not connected");

        ch.status = ChannelStatus.open;
        channelRepo.update(ch);

        recordLog(ch.tenantId, ConnectivityEventType.channelOpened,
            id, "ServiceChannel", "Channel opened: " ~ ch.name);

        return CommandResult(true, id, "");
    }

    CommandResult closeChannel(ChannelId id)
    {
        auto ch = channelRepo.findById(id);
        if (ch.id.length == 0)
            return CommandResult(false, "", "Channel not found");

        ch.status = ChannelStatus.closed;
        channelRepo.update(ch);

        recordLog(ch.tenantId, ConnectivityEventType.channelClosed,
            id, "ServiceChannel", "Channel closed: " ~ ch.name);

        return CommandResult(true, id, "");
    }

    ServiceChannel getChannel(ChannelId id)
    {
        return channelRepo.findById(id);
    }

    ServiceChannel[] listByConnector(ConnectorId connectorId)
    {
        return channelRepo.findByConnector(connectorId);
    }

    ServiceChannel[] listByTenant(TenantId tenantId)
    {
        return channelRepo.findByTenant(tenantId);
    }

    CommandResult deleteChannel(ChannelId id)
    {
        auto ch = channelRepo.findById(id);
        if (ch.id.length == 0)
            return CommandResult(false, "", "Channel not found");

        channelRepo.remove(id);
        return CommandResult(true, id, "");
    }

    private void recordLog(TenantId tenantId, ConnectivityEventType evtType,
        string sourceId, string sourceType, string message)
    {
        import std.uuid : randomUUID;

        ConnectivityLog entry;
        entry.id = randomUUID().toString();
        entry.tenantId = tenantId;
        entry.eventType = evtType;
        entry.severity = LogSeverity.info;
        entry.sourceId = sourceId;
        entry.sourceType = sourceType;
        entry.message = message;
        logRepo.save(entry);
    }
}

private ChannelType parseChannelType(string s)
{
    switch (s)
    {
    case "http": return ChannelType.http;
    case "rfc": return ChannelType.rfc;
    case "tcp": return ChannelType.tcp;
    default: return ChannelType.http;
    }
}
