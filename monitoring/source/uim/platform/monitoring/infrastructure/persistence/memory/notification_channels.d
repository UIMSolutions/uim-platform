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
class MemoryNotificationChannelRepository : NotificationChannelRepository {
  private NotificationChannel[NotificationChannelId] store;

  bool existsById(NotificationChannelId id) {
    return (id in store) ? true : false;
  }

  NotificationChannel findById(NotificationChannelId id) {
    return existsById(id) ? store[id] : NotificationChannel.init;
  }

  NotificationChannel[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  NotificationChannel[] findByType(TenantId tenantId, NotificationChannelType channelType) {
    return findByTenant(tenantId).filter!(e => e.channelType == channelType).array;
  }

  NotificationChannel[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(e => e.state == ChannelState.active).array;
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
