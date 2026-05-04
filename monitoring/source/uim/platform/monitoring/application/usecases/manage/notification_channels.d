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

    NotificationChannel channel = channels.findById(id);

    if (request.description.length > 0)
      channel.description = request.description;
    if (request.state.length > 0)
      channel.state = request.state.to!ChannelState;
    if (request.emailRecipients.length > 0)
      channel.emailRecipients = request.emailRecipients;
    if (request.emailSubjectPrefix.length > 0)
      channel.emailSubjectPrefix = request.emailSubjectPrefix;
    if (request.webhookUrl.length > 0)
      channel.webhookUrl = request.webhookUrl;
    if (request.webhookSecret.length > 0)
      channel.webhookSecret = request.webhookSecret;
    // TODO: if (request.webhookMethod.length > 0)
    //   channel.webhookMethod = request.webhookMethod;
    if (request.onPremiseHost.length > 0)
      channel.onPremiseHost = request.onPremiseHost;
    if (request.onPremisePort > 0)
      channel.onPremisePort = request.onPremisePort;
    if (request.onPremiseProtocol.length > 0)
      channel.onPremiseProtocol = request.onPremiseProtocol;

    channel.updatedAt = clockSeconds();

    channels.update(channel);
    return CommandResult(true, channel.id.value, "");
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
    return channels.findByType(tenantId, typeStr.to!NotificationChannelType);
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
