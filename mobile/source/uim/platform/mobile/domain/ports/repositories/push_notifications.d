/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.push_notifications;

import uim.platform.mobile.domain.entities.push_notification;
import uim.platform.mobile.domain.types;

interface PushNotificationRepository : ITenantRepository!(PushNotification, PushNotificationId) {

  size_t countByApp(MobileAppId appId);
  PushNotification[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByStatus(MobileAppId appId, NotificationStatus status);
  PushNotification[] findByStatus(MobileAppId appId, NotificationStatus status);
  void removeByStatus(MobileAppId appId, NotificationStatus status);

}
