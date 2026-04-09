/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.entities.notification_channel;

// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// A notification channel for delivering alert notifications.
struct NotificationChannel {
  NotificationChannelId id;
  TenantId tenantId;
  string name;
  string description;
  ChannelType channelType = ChannelType.email;
  ChannelState state = ChannelState.active;

  /// For email channels.
  string[] emailRecipients;
  string emailSubjectPrefix;

  /// For webhook channels.
  string webhookUrl;
  string webhookSecret;
  string webhookMethod;

  /// For on-premise channels.
  string onPremiseHost;
  int onPremisePort;
  string onPremiseProtocol;

  string createdBy;
  long createdAt;
  long updatedAt;
}
