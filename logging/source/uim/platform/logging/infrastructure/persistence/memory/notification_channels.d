/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.notification_channels;

// import uim.platform.logging.domain.entities.notification_channel;
// import uim.platform.logging.domain.ports.repositories.notification_channels;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:

class MemoryNotificationChannelRepository : NotificationChannelRepository {
  private NotificationChannel[NotificationChannelId] store;

  bool existsById(NotificationChannelId id) {
    return (id in store) ? true : false;
  }

  NotificationChannel findById(NotificationChannelId id) {
    return (existsById(id)) ? store[id] : NotificationChannel.init;
  }

  NotificationChannel[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(ch => ch.tenantId == tenantId).array;
  }

  NotificationChannel[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(ch => ch.state == ChannelState.active).array;
  }

  void save(NotificationChannel ch) {
    store[ch.id] = ch;
  }

  void update(NotificationChannel ch) {
    store[ch.id] = ch;
  }

  void remove(NotificationChannelId id) {
    store.remove(id);
  }

  size_t countByTenant(TenantId tenantId) {
    size_t count;
    foreach (ch; store)
      if (ch.tenantId == tenantId)
        count++;
    return count;
  }
}
