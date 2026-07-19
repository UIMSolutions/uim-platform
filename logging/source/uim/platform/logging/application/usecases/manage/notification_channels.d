/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.notification_channels;
// import uim.platform.logging.domain.entities.notification_channel;
// import uim.platform.logging.domain.ports.repositories.notification_channels;


import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageNotificationChannelsUseCase { // TODO: UIMUseCase {
  private NotificationChannelRepository repo;

  this(NotificationChannelRepository repo) {
    this.repo = repo;
  }

  CommandResult createChannel(CreateNotificationChannelRequest req) {
    import std.uuid : randomUUID;

    if (req.name.isEmpty)
      return CommandResult(false, "", "Channel name is required");

    auto channel = NotificationChannel(req.tenantId); //, req.createdBy);
    channel.name = req.name;
    channel.description = req.description;
    channel.channelType = req.channelType.to!ChannelType;
    channel.state = ChannelState.active;
    channel.emailRecipients = cast(string[]) req.emailRecipients;
    channel.emailSubjectPrefix = req.emailSubjectPrefix;
    channel.webhookUrl = req.webhookUrl;
    channel.webhookSecret = req.webhookSecret;
    channel.webhookMethod = req.webhookMethod;
    channel.slackWebhookUrl = req.slackWebhookUrl;
    channel.slackChannel = req.slackChannel;

    repo.save(channel);
    return CommandResult(true, channel.id.value, "");
  }

  CommandResult updateChannel(UpdateNotificationChannelRequest req) {
    auto channel = repo.findById(req.tenantId, req.channelId);
    if (channel.isNull)
      return CommandResult(false, "", "Notification channel not found");

    NotificationChannel updated = channel;

    if (req.description.length > 0)
      updated.description = req.description;
    if (req.state.length > 0)
      updated.state = req.state.to!ChannelState;
    if (req.emailRecipients.length > 0)
      updated.emailRecipients = cast(string[]) req.emailRecipients;
    if (req.emailSubjectPrefix.length > 0)
      updated.emailSubjectPrefix = req.emailSubjectPrefix;
    if (req.webhookUrl.length > 0)
      updated.webhookUrl = req.webhookUrl;
    if (req.webhookSecret.length > 0)
      updated.webhookSecret = req.webhookSecret;
    // TODO: if (req.webhookMethod.length > 0)
    //   updated.webhookMethod = req.webhookMethod;
    if (req.slackWebhookUrl.length > 0)
      updated.slackWebhookUrl = req.slackWebhookUrl;
    if (req.slackChannel.length > 0)
      updated.slackChannel = req.slackChannel;

    updated.updatedAt = clockSeconds();
  
    repo.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  NotificationChannel getChannel(TenantId tenantId, NotificationChannelId id) {
    return repo.findById(tenantId, id);
  }

  NotificationChannel[] listChannels(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteChannel(TenantId tenantId, NotificationChannelId id) {
    auto channel = repo.findById(tenantId, id);
    if (channel.isNull)
      return CommandResult(false, "", "Notification channel not found");

    repo.remove(channel);
    return CommandResult(true, channel.id.value, "");
  }

}
