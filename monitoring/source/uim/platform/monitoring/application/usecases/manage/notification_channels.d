/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.application.usecases.manage.notification_channels;

// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.ports.repositories.notification_channels;
// import uim.platform.monitoring.domain.types;

// // import std.conv : to;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Application service for notification channel CRUD (email, webhook, on-premise).
class ManageNotificationChannelsUseCase { // TODO: UIMUseCase {
  private NotificationChannelRepository repo;

  this(NotificationChannelRepository repo) {
    this.repo = repo;
  }

  CommandResult createChannel(CreateNotificationChannelRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Channel name is required");

    NotificationChannel ch;
    ch.id = randomUUID();
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
    return CommandResult(true, ch.id.toString, "");
  }

  CommandResult updateChannel(string id, UpdateNotificationChannelRequest req) {
    return updateChannel(NotificationChannelId(id), req);
  }

  CommandResult updateChannel(NotificationChannelId id, UpdateNotificationChannelRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Notification channel not found");

    auto ch = repo.findById(id);
    if (req.description.length > 0)
      ch.description = req.description;
    if (req.state.length > 0)
      ch.state = parseChannelState(req.state);
    if (req.emailRecipients.length > 0)
      ch.emailRecipients = req.emailRecipients;
    if (req.emailSubjectPrefix.length > 0)
      ch.emailSubjectPrefix = req.emailSubjectPrefix;
    if (req.webhookUrl.length > 0)
      ch.webhookUrl = req.webhookUrl;
    if (req.webhookSecret.length > 0)
      ch.webhookSecret = req.webhookSecret;
    if (req.onPremiseHost.length > 0)
      ch.onPremiseHost = req.onPremiseHost;
    if (req.onPremisePort > 0)
      ch.onPremisePort = req.onPremisePort;
    if (req.onPremiseProtocol.length > 0)
      ch.onPremiseProtocol = req.onPremiseProtocol;
    ch.updatedAt = clockSeconds();

    repo.update(ch);
    return CommandResult(true, id.toString, "");
  }

  bool existsChannel(string id) {
    return existsChannel(NotificationChannelId(id));
  }

  bool existsChannel(NotificationChannelId id) {
    return repo.existsById(id);
  }

  NotificationChannel getChannel(NotificationChannelId id) {
    return repo.findById(id);
  }

  NotificationChannel getChannel(string id) {
    return getChannel(NotificationChannelId(id));
  }

  NotificationChannel[] listChannels(string tenantId) {
    return listChannels(TenantId(tenantId));
  }

  NotificationChannel[] listChannels(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  NotificationChannel[] listByType(TenantId tenantId, string typeStr) {
    return repo.findByType(tenantId, parseChannelType(typeStr));
  }

  NotificationChannel[] listByType(string tenantId, string typeStr) {
    return listByType(TenantId(tenantId), typeStr);
  }

  NotificationChannel[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  NotificationChannel[] listActive(string tenantId) {
    return listActive(TenantId(tenantId));
  }

  CommandResult deleteChannel(string id) {
    return deleteChannel(NotificationChannelId(id));
  }

  CommandResult deleteChannel(NotificationChannelId id) {
    auto ch = repo.findById(id);
    if (ch.id.isEmpty)
      return CommandResult(false, "", "Notification channel not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private static ChannelType parseChannelType(string channelType) {
    switch (channelType) {
    case "webhook":
      return ChannelType.webhook;
    case "onPremise":
      return ChannelType.onPremise;
    default:
      return ChannelType.email;
    }
  }

  private static ChannelState parseChannelState(string state) {
    switch (state) {
    case "inactive":
      return ChannelState.inactive;
    case "error":
      return ChannelState.error;
    default:
      return ChannelState.active;
    }
  }
}
