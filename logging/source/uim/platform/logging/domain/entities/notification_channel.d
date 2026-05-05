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
  mixin TenantEntity!NotificationChannelId;

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
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("channelType", channelType.to!string())
      .set("state", state.to!string())
      .set("emailRecipients", emailRecipients)
      .set("emailSubjectPrefix", emailSubjectPrefix)
      .set("webhookUrl", webhookUrl)
      .set("webhookSecret", webhookSecret)
      .set("webhookMethod", webhookMethod)
      .set("slackWebhookUrl", slackWebhookUrl)
      .set("slackChannel", slackChannel);
  }
}