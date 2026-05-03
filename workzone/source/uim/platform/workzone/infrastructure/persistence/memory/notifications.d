/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.notifications;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.notification;
// import uim.platform.workzone.domain.ports.repositories.notifications;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryNotificationRepository : TenantRepository!(Notification, NotificationId), NotificationRepository {

  size_t countByRecipient(TenantId tenantId, UserId recipientId) {
    return findByRecipient(tenantId, recipientId).length;
  }

  Notification[] findByRecipient(TenantId tenantId, UserId recipientId) {
    return findByTenant(tenantId).filter!(n => n.recipientId == recipientId).array;
  }

  void removeByRecipient(TenantId tenantId, UserId recipientId) {
    findByRecipient(tenantId, recipientId).each!(n => remove(n));
  }

  size_t countUnread(TenantId tenantId, UserId recipientId) {
    return findUnread(tenantId, recipientId).length;
  }

  Notification[] findUnread(TenantId tenantId, UserId recipientId) {
    return findByTenant(tenantId).filter!(n => n.recipientId == recipientId && n.status == NotificationStatus.unread).array;
  }

  void removeUnread(TenantId tenantId, UserId recipientId) {
    findUnread(tenantId, recipientId).each!(n => remove(n));
  }

}
