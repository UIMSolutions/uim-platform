/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.notification_channel;

// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
struct NotificationChannel {
  NotificationChannelId id;
  TenantId tenantId;
  string name;
  string description;
  ChannelType channelType = ChannelType.email;
  ChannelState state = ChannelState.active;
  // Email config
  string[] emailRecipients;
  string emailSubjectPrefix;
  // Webhook config
  string webhookUrl;
  string webhookSecret;
  string webhookMethod;
  // Slack config
  string slackWebhookUrl;
  string slackChannel;
  string createdBy;
  long createdAt;
  long updatedAt;

  NotificationChannel updateFromRequest(const UpdateNotificationChannelRequest req) const {
    NotificationChannel updated = this.dup;

    if (req.description.length > 0)
      updated.description = req.description;
    if (req.state.length > 0)
      updated.state = parseChannelState(req.state);
    if (req.emailRecipients.length > 0)
      updated.emailRecipients = cast(string[]) req.emailRecipients;
    if (req.emailSubjectPrefix.length > 0)
      updated.emailSubjectPrefix = req.emailSubjectPrefix;
    if (req.webhookUrl.length > 0)
      updated.webhookUrl = req.webhookUrl;
    if (req.webhookSecret.length > 0)
      updated.webhookSecret = req.webhookSecret;
    if (req.webhookMethod.length > 0)
      updated.webhookMethod = req.webhookMethod;
    if (req.slackWebhookUrl.length > 0)
      updated.slackWebhookUrl = req.slackWebhookUrl;
    if (req.slackChannel.length > 0)
      updated.slackChannel = req.slackChannel;

    updated.updatedAt = clockSeconds();
    return updated;
  }
}