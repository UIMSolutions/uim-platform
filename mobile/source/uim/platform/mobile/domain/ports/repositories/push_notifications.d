/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.push_notifications;

import uim.platform.mobile.domain.entities.push_notification;
import uim.platform.mobile.domain.types;

interface PushNotificationRepository {
  PushNotification findById(PushNotificationId id);
  PushNotification[] findByApp(MobileAppId appId);
  PushNotification[] findByStatus(MobileAppId appId, NotificationStatus status);
  PushNotification[] findByTenant(TenantId tenantId);
  void save(PushNotification notif);
  void update(PushNotification notif);
  void remove(PushNotificationId id);
  size_t countByApp(MobileAppId appId);
  size_t countByTenant(TenantId tenantId);
}
