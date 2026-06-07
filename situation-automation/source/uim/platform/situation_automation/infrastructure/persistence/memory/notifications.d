/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.infrastructure.persistence.memory.notifications;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
class MemoryNotificationRepository : TenantRepository!(Notification, NotificationId), NotificationRepository {

    // #region ByRecipient
    size_t countByRecipient(TenantId tenantId, string recipientId) {
        return findByRecipient(tenantId, recipientId).length;
    }

    Notification[] filterByRecipient(Notification[] notifications, string recipientId) {
        return notifications.filter!(n => n.recipientId == recipientId).array;
    }

    Notification[] findByRecipient(TenantId tenantId, string recipientId) {
        return filterByRecipient(findByTenant(tenantId), recipientId);
    }

    void removeByRecipient(TenantId tenantId, string recipientId) {
        findByRecipient(tenantId, recipientId).each!(n => remove(n));
    }
    // #endregion ByRecipient

    // #region ByInstance
    size_t countByInstance(TenantId tenantId, SituationInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }

    Notification[] filterByInstance(Notification[] notifications, SituationInstanceId instanceId) {
        return notifications.filter!(n => n.situationInstanceId == instanceId).array;
    }

    Notification[] findByInstance(TenantId tenantId, SituationInstanceId instanceId) {
        return filterByInstance(findByTenant(tenantId), instanceId);
    }

    void removeByInstance(TenantId tenantId, SituationInstanceId instanceId) {
        findByInstance(tenantId, instanceId).each!(n => remove(n));
    }
    // #endregion ByInstance

    // #region ByStatus
    size_t countByStatus(TenantId tenantId, NotificationStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Notification[] filterByStatus(Notification[] notifications, NotificationStatus status) {
        return notifications.filter!(n => n.status == status).array;
    }

    Notification[] findByStatus(TenantId tenantId, NotificationStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, NotificationStatus status) {
        findByStatus(tenantId, status).each!(n => remove(n));
    }
    // #endregion ByStatus
}
