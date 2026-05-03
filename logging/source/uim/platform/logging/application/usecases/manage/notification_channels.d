/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.application.usecases.manage.notification_channels;

// import uim.platform.logging.domain.entities.notification_channel;
// import uim.platform.logging.domain.ports.repositories.notification_channels;
// import uim.platform.logging.domain.types;
// import uim.platform.logging.application.dto;

// import std.conv : to;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class ManageNotificationChannelsUseCase { // TODO: UIMUseCase {
  private NotificationChannelRepository repo;

  this(NotificationChannelRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateNotificationChannelRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Channel name is required");

    NotificationChannel channel;
    channel.id = randomUUID();
    channel.tenantId = req.tenantId;
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
    channel.createdBy = req.createdBy;
    channel.createdAt = clockSeconds();

    repo.save(channel);
    return CommandResult(true, channel.id.value, "");
  }

  CommandResult update(string id, UpdateNotificationChannelRequest req) {
    return update(NotificationChannelId(id), req);
  }

  CommandResult update(NotificationChannelId id, UpdateNotificationChannelRequest req) {
    auto channel = repo.findById(id);
    if (channel.isNull)
      return CommandResult(false, "", "Notification channel not found");

    auto updated = channel.updateFromRequest(req);
    repo.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  NotificationChannel getById(string id) {
    return getById(NotificationChannelId(id));
  }

  NotificationChannel getById(NotificationChannelId id) {
    return repo.findById(id);
  }

  NotificationChannel[] list(TenantId tenantId) {
    return list(TenantId(tenantId));
  }

  NotificationChannel[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(string id) {
    return remove(NotificationChannelId(id));
  }

  CommandResult remove(NotificationChannelId id) {
    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }

  private static ChannelState parseChannelState(string state) {
    switch (state) {
    case "active":
      return ChannelState.active;
    case "inactive":
      return ChannelState.inactive;
    case "error":
      return ChannelState.error;
    default:
      return ChannelState.active;
    }
  }
}
