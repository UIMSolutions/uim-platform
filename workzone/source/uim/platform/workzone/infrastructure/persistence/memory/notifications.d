/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.notification_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.notification;
import uim.platform.workzone.domain.ports.repositories.notifications;

// import std.algorithm : filter;
// import std.array : array;

class MemoryNotificationRepository : NotificationRepository {
  private Notification[NotificationId] store;

  Notification[] findByRecipient(UserId recipientId, TenantId tenantId) {
    return store.byValue().filter!(n => n.tenantId == tenantId && n.recipientId == recipientId)
      .array;
  }

  Notification* findById(NotificationId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Notification[] findUnread(UserId recipientId, TenantId tenantId) {
    return store.byValue().filter!(n => n.tenantId == tenantId
        && n.recipientId == recipientId && n.status == NotificationStatus.unread).array;
  }

  void save(Notification notification) {
    store[notification.id] = notification;
  }

  void update(Notification notification) {
    store[notification.id] = notification;
  }

  void remove(NotificationId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
