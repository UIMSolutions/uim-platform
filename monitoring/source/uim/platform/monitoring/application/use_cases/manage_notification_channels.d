module uim.platform.xyz.application.usecases.manage_notification_channels;

import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.notification_channel;
import uim.platform.xyz.domain.ports.notification_channel_repository;
import uim.platform.xyz.domain.types;

import std.conv : to;

/// Application service for notification channel CRUD (email, webhook, on-premise).
class ManageNotificationChannelsUseCase
{
    private NotificationChannelRepository repo;

    this(NotificationChannelRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createChannel(CreateNotificationChannelRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Channel name is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        NotificationChannel ch;
        ch.id = id;
        ch.tenantId = req.tenantId;
        ch.name = req.name;
        ch.description = req.description;
        ch.channelType = parseChannelType(req.channelType);
        ch.state = ChannelState.active;

        // Email fields
        ch.emailRecipients = req.emailRecipients;
        ch.emailSubjectPrefix = req.emailSubjectPrefix;

        // Webhook fields
        ch.webhookUrl = req.webhookUrl;
        ch.webhookSecret = req.webhookSecret;
        ch.webhookMethod = req.webhookMethod.length > 0 ? req.webhookMethod : "POST";

        // On-premise fields
        ch.onPremiseHost = req.onPremiseHost;
        ch.onPremisePort = req.onPremisePort;
        ch.onPremiseProtocol = req.onPremiseProtocol;

        ch.createdBy = req.createdBy;
        ch.createdAt = clockSeconds();
        ch.updatedAt = ch.createdAt;

        repo.save(ch);
        return CommandResult(true, id, "");
    }

    CommandResult updateChannel(NotificationChannelId id, UpdateNotificationChannelRequest req)
    {
        auto ch = repo.findById(id);
        if (ch.id.length == 0)
            return CommandResult(false, "", "Notification channel not found");

        if (req.description.length > 0) ch.description = req.description;
        if (req.state.length > 0) ch.state = parseChannelState(req.state);
        if (req.emailRecipients.length > 0) ch.emailRecipients = req.emailRecipients;
        if (req.emailSubjectPrefix.length > 0) ch.emailSubjectPrefix = req.emailSubjectPrefix;
        if (req.webhookUrl.length > 0) ch.webhookUrl = req.webhookUrl;
        if (req.webhookSecret.length > 0) ch.webhookSecret = req.webhookSecret;
        if (req.onPremiseHost.length > 0) ch.onPremiseHost = req.onPremiseHost;
        if (req.onPremisePort > 0) ch.onPremisePort = req.onPremisePort;
        ch.updatedAt = clockSeconds();

        repo.update(ch);
        return CommandResult(true, id, "");
    }

    NotificationChannel getChannel(NotificationChannelId id)
    {
        return repo.findById(id);
    }

    NotificationChannel[] listChannels(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    NotificationChannel[] listByType(TenantId tenantId, string typeStr)
    {
        return repo.findByType(tenantId, parseChannelType(typeStr));
    }

    NotificationChannel[] listActive(TenantId tenantId)
    {
        return repo.findActive(tenantId);
    }

    CommandResult deleteChannel(NotificationChannelId id)
    {
        auto ch = repo.findById(id);
        if (ch.id.length == 0)
            return CommandResult(false, "", "Notification channel not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }

    private static ChannelType parseChannelType(string s)
    {
        switch (s)
        {
            case "webhook":     return ChannelType.webhook;
            case "onPremise":   return ChannelType.onPremise;
            default:            return ChannelType.email;
        }
    }

    private static ChannelState parseChannelState(string s)
    {
        switch (s)
        {
            case "inactive":    return ChannelState.inactive;
            case "error":       return ChannelState.error;
            default:            return ChannelState.active;
        }
    }
}
