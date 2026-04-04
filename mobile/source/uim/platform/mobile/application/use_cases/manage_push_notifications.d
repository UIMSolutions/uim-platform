/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.use_cases.manage_push_notifications;

import uim.platform.mobile.domain.ports.push_notification_repository;
import uim.platform.mobile.domain.entities.push_notification;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.domain.services.push_delivery_service;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManagePushNotificationsUseCase : UIMUseCase {
    private PushNotificationRepository repo;

    this(PushNotificationRepository repo) {
        this.repo = repo;
    }

    CommandResult send(SendPushNotificationRequest r) {
        auto provider = parseProvider(r.provider);
        if (!PushDeliveryService.validatePayloadSize(r.payload, provider))
            return CommandResult(false, "", "Payload exceeds maximum size for provider");
        PushNotification notif;
        notif.id = randomUUID().to!string;
        notif.tenantId = r.tenantId;
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
        notif.createdAt = currentTimestamp();
        notif.createdBy = r.createdBy;
        repo.save(notif);
        return CommandResult(true, notif.id, "");
    }

    PushNotification get_(PushNotificationId id) {
        return repo.findById(id);
    }

    PushNotification[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    PushNotification[] listByStatus(MobileAppId appId, string status) {
        return repo.findByStatus(appId, parseNotifStatus(status));
    }

    void remove(PushNotificationId id) {
        repo.remove(id);
    }

    long countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static PushProvider parseProvider(string s) {
        switch (s) {
            case "apns": return PushProvider.apns;
            case "fcm": return PushProvider.fcm;
            case "wns": return PushProvider.wns;
            case "webpush": return PushProvider.webpush;
            default: return PushProvider.fcm;
        }
    }

    private static NotificationPriority parsePriority(string s) {
        switch (s) {
            case "high": return NotificationPriority.high;
            case "normal": return NotificationPriority.normal;
            case "low": return NotificationPriority.low;
            default: return NotificationPriority.normal;
        }
    }

    private static NotificationStatus parseNotifStatus(string s) {
        switch (s) {
            case "pending": return NotificationStatus.pending;
            case "sent": return NotificationStatus.sent;
            case "delivered": return NotificationStatus.delivered;
            case "failed": return NotificationStatus.failed;
            default: return NotificationStatus.pending;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
