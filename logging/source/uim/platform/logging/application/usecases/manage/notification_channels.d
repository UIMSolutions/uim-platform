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
class ManageNotificationChannelsUseCase : UIMUseCase {
  private NotificationChannelRepository repo;

  this(NotificationChannelRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateNotificationChannelRequest req) {
    import std.uuid : randomUUID;

    if (req.name.length == 0)
      return CommandResult(false, "", "Channel name is required");

    NotificationChannel ch;
    ch.id = randomUUID().to!string;
    ch.tenantId = req.tenantId;
    ch.name = req.name;
    ch.description = req.description;
    ch.channelType = parseChannelType(req.channelType);
    ch.state = ChannelState.active;
    ch.emailRecipients = cast(string[]) req.emailRecipients;
    ch.emailSubjectPrefix = req.emailSubjectPrefix;
    ch.webhookUrl = req.webhookUrl;
    ch.webhookSecret = req.webhookSecret;
    ch.webhookMethod = req.webhookMethod;
    ch.slackWebhookUrl = req.slackWebhookUrl;
    ch.slackChannel = req.slackChannel;
    ch.createdBy = req.createdBy;
    ch.createdAt = clockSeconds();

    repo.save(ch);
    return CommandResult(true, ch.id, "");
  }

  CommandResult update(NotificationChannelId id, UpdateNotificationChannelRequest req) {
    auto ch = repo.findById(id);
    if (ch.id.isEmpty)
      return CommandResult(false, "", "Notification channel not found");

    if (req.description.length > 0)
      ch.description = req.description;
    if (req.state.length > 0)
      ch.state = parseChannelState(req.state);
    if (req.emailRecipients.length > 0)
      ch.emailRecipients = cast(string[]) req.emailRecipients;
    if (req.emailSubjectPrefix.length > 0)
      ch.emailSubjectPrefix = req.emailSubjectPrefix;
    if (req.webhookUrl.length > 0)
      ch.webhookUrl = req.webhookUrl;
    if (req.webhookSecret.length > 0)
      ch.webhookSecret = req.webhookSecret;
    if (req.slackWebhookUrl.length > 0)
      ch.slackWebhookUrl = req.slackWebhookUrl;
    if (req.slackChannel.length > 0)
      ch.slackChannel = req.slackChannel;
    ch.updatedAt = clockSeconds();

    repo.update(ch);
    return CommandResult(true, id, "");
  }

  NotificationChannel get_(NotificationChannelId id) {
    return repo.findById(id);
  }

  NotificationChannel[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(NotificationChannelId id) {
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private static ChannelType parseChannelType(string s) {
    switch (s) {
    case "email":
      return ChannelType.email;
    case "webhook":
      return ChannelType.webhook;
    case "slack":
      return ChannelType.slack;
    default:
      return ChannelType.email;
    }
  }

  private static ChannelState parseChannelState(string s) {
    switch (s) {
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

  private static long clockSeconds() {
    import core.time : MonoTime;

    return MonoTime.currTime.ticks / MonoTime.ticksPerSecond;
  }
}
