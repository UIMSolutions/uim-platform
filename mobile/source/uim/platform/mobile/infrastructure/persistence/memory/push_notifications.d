/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.push_notifications;
// import uim.platform.mobile.domain.entities.push_notification;
// import uim.platform.mobile.domain.ports.repositories.push_notifications;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryPushNotificationRepository : TenantRepository!(PushNotification, PushNotificationId), PushNotificationRepository {

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  PushNotification[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(find(tenantId).array, appId);
  }

  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(n => remove(n));
  }

  size_t countByStatus(TenantId tenantId, MobileAppId appId, NotificationStatus status) {
    return findByStatus(tenantId, appId, status).length;
  }

  PushNotification[] filterByStatus(PushNotification[] notifications, NotificationStatus status) {
    return notifications.filter!(n => n.status == status).array;
  }

  PushNotification[] findByStatus(TenantId tenantId, MobileAppId appId, NotificationStatus status) {
    return filterByStatus(findByApp(tenantId, appId), status);
  }

  void removeByStatus(TenantId tenantId, MobileAppId appId, NotificationStatus status) {
    findByStatus(tenantId, appId, status).each!(n => remove(n));
  }

}
