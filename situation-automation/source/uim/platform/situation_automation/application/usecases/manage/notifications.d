/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.notifications;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
class ManageNotificationsUseCase { // TODO: UIMUseCase {
    private NotificationRepository repo;

    this(NotificationRepository repo) {
        this.repo = repo;
    }

    CommandResult createNotification(CreateNotificationRequest r) {
        if (r.notificationId.isEmpty)
            return CommandResult(false, "", "Notification ID is required");
        if (r.recipientId.isEmpty)
            return CommandResult(false, "", "Recipient ID is required");

        auto existing = repo.findById(r.tenantId, r.notificationId);
        if (!existing.isNull)
            return CommandResult(false, "", "Notification already exists");

        Notification n;
        n.initEntity(r.tenantId, r.notificationId);

        n.situationInstanceId = r.situationInstanceId;
        n.recipientId = r.recipientId.value;
        n.title = r.title;
        n.message = r.message;
        n.status = NotificationStatus.pending;
        n.actionUrl = r.actionUrl;

        repo.save(n);
        return CommandResult(true, n.id.value, "");
    }

    Notification getNotification(TenantId tenantId, NotificationId id) {
        return repo.findById(tenantId, id);
    }

    Notification[] listNotifications(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Notification[] listNotifications(TenantId tenantId, string recipientId) {
        return repo.findByRecipient(tenantId, recipientId);
    }

    Notification[] listNotifications(TenantId tenantId, SituationInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult updateNotification(UpdateNotificationRequest r) {
        auto notification = repo.findById(r.tenantId, r.notificationId);
        if (notification.isNull)
            return CommandResult(false, "", "Notification not found");

        
        auto now = currentTimestamp;

        if (r.status == "sent") {
            notification.status = NotificationStatus.sent;
            notification.sentAt = now;
        } else if (r.status == "read") {
            notification.status = NotificationStatus.read_;
            notification.readAt = now;
        } else if (r.status == "acknowledged") {
            notification.status = NotificationStatus.acknowledged;
        }

        repo.update(notification);
        return CommandResult(true, notification.id.value, "");
    }

    CommandResult deleteNotification(TenantId tenantId, NotificationId id) {
        auto notification = repo.findById(tenantId, id);
        if (notification.isNull)
            return CommandResult(false, "", "Notification not found");

        repo.remove(notification);
        return CommandResult(true, notification.id.value, "");
    }
}
