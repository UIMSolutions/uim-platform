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

  NotificationChannel createFromRequest(const CreateNotificationChannelRequest req) {
    NotificationChannel channel;
    
    channel.id = randomUUID();
    channel.tenantId = req.tenantId;
    channel.name = req.name;
    channel.description = req.description;
    channel.channelType = req.channelType.to!NotificationChannelType;
    channel.state = ChannelState.active;

    // Email fields
    channel.emailRecipients = req.emailRecipients;
    channel.emailSubjectPrefix = req.emailSubjectPrefix;

    // Webhook fields
    channel.webhookUrl = req.webhookUrl;
    channel.webhookSecret = req.webhookSecret;
    channel.webhookMethod = req.webhookMethod.length > 0 ? req.webhookMethod : "POST";

    // On-premise fields
    channel.onPremiseHost = req.onPremiseHost;
    channel.onPremisePort = req.onPremisePort;
    channel.onPremiseProtocol = req.onPremiseProtocol;

    channel.createdBy = req.createdBy;
    channel.createdAt = clockSeconds();
    channel.updatedAt = channel.createdAt;

    return channel;
  }

  NotificationChannel updateFromRequest(const UpdateNotificationChannelRequest req) const {
    NotificationChannel updated = this.dup;

    if (req.description.length > 0)
      updated.description = req.description;
    if (req.state.length > 0)
      updated.state = parseChannelState(req.state);
    if (req.emailRecipients.length > 0)
      updated.emailRecipients = req.emailRecipients;
    if (req.emailSubjectPrefix.length > 0)
      updated.emailSubjectPrefix = req.emailSubjectPrefix;
    if (req.webhookUrl.length > 0)
      updated.webhookUrl = req.webhookUrl;
    if (req.webhookSecret.length > 0)
      updated.webhookSecret = req.webhookSecret;
    if (req.webhookMethod.length > 0)
      updated.webhookMethod = req.webhookMethod;
    if (req.onPremiseHost.length > 0)
      updated.onPremiseHost = req.onPremiseHost;
    if (req.onPremisePort > 0)
      updated.onPremisePort = req.onPremisePort;
    if (req.onPremiseProtocol.length > 0)
      updated.onPremiseProtocol = req.onPremiseProtocol;

    updated.updatedAt = clockSeconds();
    return updated;
  }
}
