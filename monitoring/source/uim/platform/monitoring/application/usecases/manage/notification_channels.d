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
  private NotificationChannelRepository channels;

  this(NotificationChannelRepository channels) {
    this.channels = channels;
  }

  CommandResult createChannel(CreateNotificationChannelRequest request) {
    if (request.name.length == 0)
      return CommandResult(false, "", "Channel name is required");

    NotificationChannel channel;
    
    channel.id = randomUUID();
    channel.tenantId = request.tenantId;
    channel.name = request.name;
    channel.description = request.description;
    channel.channelType = request.channelType.to!NotificationChannelType;
    channel.state = ChannelState.active;

    // Email fields
    channel.emailRecipients = request.emailRecipients;
    channel.emailSubjectPrefix = request.emailSubjectPrefix;

    // Webhook fields
    channel.webhookUrl = request.webhookUrl;
    channel.webhookSecret = request.webhookSecret;
    channel.webhookMethod = request.webhookMethod.length > 0 ? request.webhookMethod : "POST";

    // On-premise fields
    channel.onPremiseHost = request.onPremiseHost;
    channel.onPremisePort = request.onPremisePort;
    channel.onPremiseProtocol = request.onPremiseProtocol;

    channel.createdBy = request.createdBy;
    channel.createdAt = clockSeconds();
    channel.updatedAt = channel.createdAt;

    channels.save(channel);
    return CommandResult(true, channel.id.value, "");
  }

  CommandResult updateChannel(string id, UpdateNotificationChannelRequest request) {
    return updateChannel(NotificationChannelId(id), request);
  }

  CommandResult updateChannel(NotificationChannelId id, UpdateNotificationChannelRequest request) {
    if (!channels.existsById(id))
      return CommandResult(false, "", "Notification channel not found");

    auto channel = channels.findById(id);
    NotificationChannel updated = channel.dup;

    if (req.description.length > 0)
      updated.description = req.description;
    if (req.state.length > 0)
      updated.state = parseChannelState(req.state);
    if (req.emailRecipients.length > 0)
      updated.emailRecipients = req.emailRecipients;
    if (req.emailSubjectPrefix.length > 0)
      updated.emailSubjectPrefix = req.emailSubjectPrefix;
    if (req.webhookUrl.length > 0)
      updated.webhookUrl = req.webhookUrl;
    if (req.webhookSecret.length > 0)
      updated.webhookSecret = req.webhookSecret;
    if (req.webhookMethod.length > 0)
      updated.webhookMethod = req.webhookMethod;
    if (req.onPremiseHost.length > 0)
      updated.onPremiseHost = req.onPremiseHost;
    if (req.onPremisePort > 0)
      updated.onPremisePort = req.onPremisePort;
    if (req.onPremiseProtocol.length > 0)
      updated.onPremiseProtocol = req.onPremiseProtocol;

    updated.updatedAt = clockSeconds();

    channels.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  bool existsChannel(NotificationChannelId id) {
    return channels.existsById(id);
  }

  NotificationChannel getChannel(NotificationChannelId id) {
    return channels.findById(id);
  }

  NotificationChannel[] listChannels(TenantId tenantId) {
    return channels.findByTenant(tenantId);
  }

  NotificationChannel[] listByType(TenantId tenantId, string typeStr) {
    return channels.findByType(tenantId, typeStr.to!ChannelType);
  }

  NotificationChannel[] listActive(TenantId tenantId) {
    return channels.findActive(tenantId);
  }

  CommandResult deleteChannel(string id) {
    return deleteChannel(NotificationChannelId(id));
  }

  CommandResult deleteChannel(NotificationChannelId id) {
    auto ch = channels.findById(id);
    if (ch.isNull)
      return CommandResult(false, "", "Notification channel not found");

    channels.removeById(id);
    return CommandResult(true, id.value, "");
  }


}
