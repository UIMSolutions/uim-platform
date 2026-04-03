/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.notification_channel_repo;

import uim.platform.logging.domain.entities.notification_channel;
import uim.platform.logging.domain.ports.notification_channel_repository;
import uim.platform.logging.domain.types;

class MemoryNotificationChannelRepository : NotificationChannelRepository {
  private NotificationChannel[NotificationChannelId] store;

  NotificationChannel findById(NotificationChannelId id) {
    if (auto p = id in store)
      return *p;
    return NotificationChannel.init;
  }

  NotificationChannel[] findByTenant(TenantId tenantId) {
    NotificationChannel[] result;
    foreach (ref ch; store)
      if (ch.tenantId == tenantId)
        result ~= ch;
    return result;
  }

  NotificationChannel[] findActive(TenantId tenantId) {
    NotificationChannel[] result;
    foreach (ref ch; store)
      if (ch.tenantId == tenantId && ch.state == ChannelState.active)
        result ~= ch;
    return result;
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

  long countByTenant(TenantId tenantId) {
    long count;
    foreach (ref ch; store)
      if (ch.tenantId == tenantId)
        count++;
    return count;
  }
}
