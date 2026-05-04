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
  mixin TenantEntity!(NotificationChannelId);

  string name;
  string description;
  NotificationChannelType channelType = NotificationChannelType.email;
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

  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("description", description)
      .set("channelType", channelType.toString())
      .set("state", state.toString())
      .set("emailRecipients", emailRecipients)
      .set("emailSubjectPrefix", emailSubjectPrefix)
      .set("webhookUrl", webhookUrl)
      .set("webhookSecret", webhookSecret)
      .set("webhookMethod", webhookMethod)
      .set("onPremiseHost", onPremiseHost)
      .set("onPremisePort", onPremisePort)
      .set("onPremiseProtocol", onPremiseProtocol);

    return j;
  }

}
