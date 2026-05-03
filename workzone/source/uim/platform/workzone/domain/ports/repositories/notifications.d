/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.notifications;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.notification;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface NotificationRepository : ITenantRepository!(Notification, NotificationId) {

  size_t countByRecipient(TenantId tenantId, UserId recipientId);
  Notification[] findByRecipient(TenantId tenantId, UserId recipientId);
  void removeByRecipient(TenantId tenantId, UserId recipientId);

  size_t countUnread(TenantId tenantId, UserId recipientId);
  Notification[] findUnread(TenantId tenantId, UserId recipientId);
  void removeUnread(TenantId tenantId, UserId recipientId);
  
}
