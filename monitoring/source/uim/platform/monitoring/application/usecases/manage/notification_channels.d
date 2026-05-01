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

// // import std.conv : to;
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

    NotificationChannel channel = NotificationChannel.createFromRequest(request);
    channels.save(channel);

    return CommandResult(true, channel.id.toString, "");
  }

  CommandResult updateChannel(string id, UpdateNotificationChannelRequest request) {
    return updateChannel(NotificationChannelId(id), request);
  }

  CommandResult updateChannel(NotificationChannelId id, UpdateNotificationChannelRequest request) {
    if (!channels.existsById(id))
      return CommandResult(false, "", "Notification channel not found");

    auto ch = channels.findById(id);
    auto updated = ch.updateFromRequest(request);
    channels.update(updated);

    return CommandResult(true, id.toString, "");
  }

  bool existsChannel(string id) {
    return existsChannel(NotificationChannelId(id));
  }

  bool existsChannel(NotificationChannelId id) {
    return channels.existsById(id);
  }

  NotificationChannel getChannel(NotificationChannelId id) {
    return channels.findById(id);
  }

  NotificationChannel getChannel(string id) {
    return getChannel(NotificationChannelId(id));
  }

  NotificationChannel[] listChannels(string tenantId) {
    return listChannels(TenantId(tenantId));
  }

  NotificationChannel[] listChannels(TenantId tenantId) {
    return channels.findByTenant(tenantId);
  }

  NotificationChannel[] listByType(TenantId tenantId, string typeStr) {
    return channels.findByType(tenantId, parseChannelType(typeStr));
  }

  NotificationChannel[] listByType(string tenantId, string typeStr) {
    return listByType(TenantId(tenantId), typeStr);
  }

  NotificationChannel[] listActive(TenantId tenantId) {
    return channels.findActive(tenantId);
  }

  NotificationChannel[] listActive(string tenantId) {
    return listActive(TenantId(tenantId));
  }

  CommandResult deleteChannel(string id) {
    return deleteChannel(NotificationChannelId(id));
  }

  CommandResult deleteChannel(NotificationChannelId id) {
    auto ch = channels.findById(id);
    if (ch.isNull)
      return CommandResult(false, "", "Notification channel not found");

    channels.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private static ChannelState parseChannelState(string state) {
    switch (state) {
    case "inactive":
      return ChannelState.inactive;
    case "error":
      return ChannelState.error;
    default:
      return ChannelState.active;
    }
  }
}
