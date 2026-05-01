/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.notifications;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageNotificationsUseCase { // TODO: UIMUseCase {
    private NotificationRepository repo;

    this(NotificationRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateNotificationRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "Notification ID is required");
        if (r.recipientId.isEmpty)
            return CommandResult(false, "", "Recipient ID is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Notification already exists");

        Notification n;
        n.id = r.id;
        n.instanceId = r.instanceId;
        n.tenantId = r.tenantId;
        n.recipientId = r.recipientId;
        n.title = r.title;
        n.message = r.message;
        n.status = NotificationStatus.pending;
        n.actionUrl = r.actionUrl;

        import core.time : MonoTime;
        n.createdAt = MonoTime.currTime.ticks;

        repo.save(n);
        return CommandResult(true, n.id, "");
    }

    Notification getById(NotificationId id) {
        return repo.findById(id);
    }

    Notification[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Notification[] listByRecipient(TenantId tenantId, string recipientId) {
        return repo.findByRecipient(tenantId, recipientId);
    }

    Notification[] listByInstance(SituationInstanceId instanceId) {
        return repo.findByInstance(instanceId);
    }

    CommandResult update(UpdateNotificationRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Notification not found");

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;

        if (r.status == "sent") {
            existing.status = NotificationStatus.sent;
            existing.sentAt = now;
        } else if (r.status == "read") {
            existing.status = NotificationStatus.read_;
            existing.readAt = now;
        } else if (r.status == "acknowledged") {
            existing.status = NotificationStatus.acknowledged;
        }

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(NotificationId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Notification not found");

        repo.removeById(id);
        return CommandResult(true, id.toString, "");
    }
}
