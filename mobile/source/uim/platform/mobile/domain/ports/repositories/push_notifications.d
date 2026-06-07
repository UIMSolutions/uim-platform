/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.push_notifications;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface PushNotificationRepository : ITenantRepository!(PushNotification, PushNotificationId) {

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  PushNotification[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByStatus(TenantId tenantId, MobileAppId appId, NotificationStatus status);
  PushNotification[] findByStatus(TenantId tenantId, MobileAppId appId, NotificationStatus status);
  void removeByStatus(MobileAppId appId, NotificationStatus status);

}
