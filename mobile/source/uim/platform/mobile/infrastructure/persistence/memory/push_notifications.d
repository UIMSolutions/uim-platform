/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.push_notification;

import uim.platform.mobile.domain.entities.push_notification;
import uim.platform.mobile.domain.ports.repositories.push_notifications;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryPushNotificationRepository : TenantRepository!(PushNotification, PushNotificationId), PushNotificationRepository {

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }
  PushNotification[] filterByApp(PushNotification[] notifications, MobileAppId appId) {
    return notifications.filter!(n => n.appId == appId).array;
  }
  PushNotification[] findByApp(MobileAppId appId) {
    return filterByApp(store.values.array, appId);
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(n => remove(n));
  }

  size_t countByStatus(MobileAppId appId, NotificationStatus status) {
    return findByStatus(appId, status).length;
  }
  PushNotification[] filterByStatus(PushNotification[] notifications, NotificationStatus status) {  
    return notifications.filter!(n => n.status == status).array;
  }
  PushNotification[] findByStatus(MobileAppId appId, NotificationStatus status) {
    return filterByStatus(findByApp(appId), status);
  }   
  void removeByStatus(MobileAppId appId, NotificationStatus status) {
    findByStatus(appId, status).each!(n => remove(n));
  }

}
