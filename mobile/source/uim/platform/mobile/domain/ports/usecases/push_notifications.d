/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.push_notifications;
// import uim.platform.mobile.domain.ports.repositories.push_notifications;
// import uim.platform.mobile.domain.entities.push_notification;

// import uim.platform.mobile.domain.services.push_delivery_service;
// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManagePushNotificationsUseCase {

    CommandResult send(SendPushNotificationRequest r);

    PushNotification getNotification(TenantId tenantId, PushNotificationId id);

    PushNotification[] listNotifications(TenantId tenantId);

    PushNotification[] listNotifications(TenantId tenantId, MobileAppId appId);

    PushNotification[] listNotifications(TenantId tenantId, MobileAppId appId, string status);

    CommandResult deleteNotification(TenantId tenantId, PushNotificationId id);

    size_t countByApp(TenantId tenantId, MobileAppId appId);

}