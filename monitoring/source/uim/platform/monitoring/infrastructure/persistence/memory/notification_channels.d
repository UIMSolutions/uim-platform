/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.notification_channel;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.notification_channel;
// import uim.platform.monitoring.domain.ports.repositories.notification_channels;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryNotificationChannelRepository : NotificationChannelRepository {
  private NotificationChannel[NotificationChannelId] store;

  NotificationChannel findById(NotificationChannelId id) {
    if (auto p = id in store)
      return *p;
    return NotificationChannel.init;
  }

  NotificationChannel[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  NotificationChannel[] findByType(TenantId tenantId, ChannelType channelType) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.channelType == channelType)
      .array;
  }

  NotificationChannel[] findActive(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.state == ChannelState.active).array;
  }

  void save(NotificationChannel channel) {
    store[channel.id] = channel;
  }

  void update(NotificationChannel channel) {
    store[channel.id] = channel;
  }

  void remove(NotificationChannelId id) {
    store.remove(id);
  }
}
