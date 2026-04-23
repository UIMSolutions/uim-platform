/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.notifications;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.notification;

interface NotificationRepository {
  Notification[] findByRecipient(TenantId tenantId, UserId recipientId);
  Notification* findById(NotificationId notificationId, TenantId tenantId);
  Notification[] findUnread(TenantId tenantId, UserId recipientId);
  void save(Notification notification);
  void update(Notification notification);
  void remove(NotificationId notificationId, TenantId tenantId);
}
