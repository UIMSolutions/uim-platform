/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.notifications;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryNotificationRepository :TenantRepository!(Notification, NotificationId), NotificationRepository {
    private Notification[] store;

    Notification findById(NotificationId id) {
        foreach (n; findAll) {
            if (n.id == id)
                return n;
        }
        return Notification.init;
    }

    Notification[] findByTenant(TenantId tenantId) {
        return findAll().filter!(n => n.tenantId == tenantId).array;
    }

    Notification[] findByRecipient(TenantId tenantId, string recipientId) {
        return findAll().filter!(n => n.tenantId == tenantId && n.recipientId == recipientId).array;
    }

    Notification[] findByInstance(SituationInstanceId instanceId) {
        return findAll().filter!(n => n.instanceId == instanceId).array;
    }

    Notification[] findByStatus(TenantId tenantId, NotificationStatus status) {
        return findAll().filter!(n => n.tenantId == tenantId && n.status == status).array;
    }

}
