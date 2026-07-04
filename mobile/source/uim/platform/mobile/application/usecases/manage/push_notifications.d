/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.push_notifications;
// import uim.platform.mobile.domain.ports.repositories.push_notifications;
// import uim.platform.mobile.domain.entities.push_notification;

// import uim.platform.mobile.domain.services.push_delivery_service;
// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManagePushNotificationsUseCase { // TODO: UIMUseCase {
    private PushNotificationRepository repo;

    this(PushNotificationRepository repo) {
        this.repo = repo;
    }

    CommandResult send(SendPushNotificationRequest r) {
        auto provider = parseProvider(r.provider);
        if (!PushDeliveryService.validatePayloadSize(r.payload, provider))
            return CommandResult(false, "", "Payload exceeds maximum size for provider");
        
        auto notif = PushNotification(r.tenantId);
        notif.appId = r.appId;
        notif.title = r.title;
        notif.body_ = r.body_;
        notif.payload = r.payload;
        notif.provider = provider;
        notif.status = NotificationStatus.pending;
        notif.priority = parsePriority(r.priority);
        notif.targetDevices = r.targetDevices;
        notif.targetTopics = r.targetTopics;
        notif.scheduledAt = r.scheduledAt;
        notif.expiresAt = r.expiresAt;

        repo.save(notif);
        return CommandResult(true, notif.id.value, "");
    }

    PushNotification getNotification(TenantId tenantId, PushNotificationId id) {
        return repo.findById(tenantId, id);
    }

    PushNotification[] listNotifications(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    PushNotification[] listNotifications(TenantId tenantId, MobileAppId appId, string status) {
        return repo.findByStatus(tenantId, appId, parseNotifStatus(status));
    }

    CommandResult deleteNotification(TenantId tenantId, PushNotificationId id) {
        auto notif = repo.findById(tenantId, id);
        if (notif.isNull)
            return CommandResult(false, "", "Notification not found");

        repo.remove(notif);
        return CommandResult(true, notif.id.value, "");
    }

    size_t countByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }


}