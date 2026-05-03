/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.notifications;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class MemoryNotificationRepository : TenantRepository!(Notification, NotificationId), NotificationRepository {

    size_t countByRecipient(TenantId tenantId, string recipientId) {
        return findByRecipient(tenantId, recipientId).length;
    }
    Notification[] findByRecipient(TenantId tenantId, string recipientId) {
        return findAll().filter!(n => n.tenantId == tenantId && n.recipientId == recipientId).array;
    }
    void removeByRecipient(TenantId tenantId, string recipientId) {
        findByRecipient(tenantId, recipientId).each!(n => remove(n.id));
    }

    size_t countByInstance(SituationInstanceId instanceId) {
        return findByInstance(instanceId).length;
    }
    Notification[] findByInstance(SituationInstanceId instanceId) {
        return findAll().filter!(n => n.instanceId == instanceId).array;
    }
    void removeByInstance(SituationInstanceId instanceId) {
        findByInstance(instanceId).each!(n => remove(n.id));
    }

    size_t countByStatus(TenantId tenantId, NotificationStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Notification[] findByStatus(TenantId tenantId, NotificationStatus status) {
        return findAll().filter!(n => n.tenantId == tenantId && n.status == status).array;
    }
    void removeByStatus(TenantId tenantId, NotificationStatus status) {
        findByStatus(tenantId, status).each!(n => remove(n.id));
    }

}
