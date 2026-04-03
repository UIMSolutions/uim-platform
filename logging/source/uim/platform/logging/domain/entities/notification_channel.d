/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.notification_channel;

import uim.platform.logging.domain.types;

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
}
