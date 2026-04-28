/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.notification_channels;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.ports.repositories.notification_channels;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryNotificationChannelRepository : TenantRepository!(NotificationChannel, NotificationChannelId), NotificationChannelRepository {

  size_t countByType(TenantId tenantId, NotificationChannelType channelType) {
    return findByType(tenantId, channelType).length;
  }

  NotificationChannel[] filterByType(NotificationChannel[] channels, NotificationChannelType channelType) {
    return channels.filter!(e => e.channelType == channelType).array;
  }

  NotificationChannel[] findByType(TenantId tenantId, NotificationChannelType channelType) {
    return findByTenant(tenantId).filter!(e => e.channelType == channelType).array;
  }

  void removeByType(TenantId tenantId, NotificationChannelType channelType) {
    findByType(tenantId, channelType).each!(e => remove(e));
  }

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }

  NotificationChannel[] filterActive(NotificationChannel[] channels) {
    return channels.filter!(e => e.state == ChannelState.active).array;
  }

  NotificationChannel[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(e => e.state == ChannelState.active).array;
  }

  void removeActive(TenantId tenantId) {
    findActive(tenantId).each!(e => remove(e));
  }

}
