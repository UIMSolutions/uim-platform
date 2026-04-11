/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.notifications;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryNotificationRepository : NotificationRepository {
    private Notification[] store;

    Notification findById(NotificationId id) {
        foreach (n; store) {
            if (n.id == id)
                return n;
        }
        return Notification.init;
    }

    Notification[] findByTenant(TenantId tenantId) {
        return store.filter!(n => n.tenantId == tenantId).array;
    }

    Notification[] findByRecipient(TenantId tenantId, string recipientId) {
        return store.filter!(n => n.tenantId == tenantId && n.recipientId == recipientId).array;
    }

    Notification[] findByInstance(SituationInstanceId instanceId) {
        return store.filter!(n => n.instanceId == instanceId).array;
    }

    Notification[] findByStatus(TenantId tenantId, NotificationStatus status) {
        return store.filter!(n => n.tenantId == tenantId && n.status == status).array;
    }

    void save(Notification n) {
        store ~= n;
    }

    void update(Notification n) {
        foreach (existing; store) {
            if (existing.id == n.id) {
                existing = n;
                return;
            }
        }
    }

    void remove(NotificationId id) {
        store = store.filter!(n => n.id != id).array;
    }

    size_t countByTenant(TenantId tenantId) {
        return cast(long) store.filter!(n => n.tenantId == tenantId).array.length;
    }
}
