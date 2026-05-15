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
// 
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

    channel.initEntity(request.tenantId, request.createdBy);
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

    channels.save(channel);
    return CommandResult(true, channel.id.value, "");
  }

  CommandResult updateChannel(UpdateNotificationChannelRequest request) {
    NotificationChannel channel = channels.findById(request.tenantId, request.id);

    if (channel.isNull)
      return CommandResult(false, "", "Notification channel not found");

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

  bool existsChannel(TenantId tenantId, NotificationChannelId id) {
    return channels.existsById(tenantId, id);
  }

  NotificationChannel getChannel(TenantId tenantId, NotificationChannelId id) {
    return channels.findById(tenantId, id);
  }

  NotificationChannel[] listChannels(TenantId tenantId) {
    return channels.findByTenant(tenantId);
  }

  NotificationChannel[] listActive(TenantId tenantId) {
    return channels.findActive(tenantId);
  }

  CommandResult activateChannel(TenantId tenantId, NotificationChannelId id) {
    auto channel = channels.findById(tenantId, id);
    if (channel.isNull)
      return CommandResult(false, "", "Notification channel not found");

    channel.state = ChannelState.active;
    channel.updatedAt = clockSeconds();
    channels.update(channel);
    return CommandResult(true, channel.id.value, "");
  }

  CommandResult deleteChannel(TenantId tenantId, NotificationChannelId id) {
    auto channel = channels.findById(tenantId, id);
    if (channel.isNull)
      return CommandResult(false, "", "Notification channel not found");

    channels.remove(channel);
    return CommandResult(true, channel.id.value, "");
  }

}
