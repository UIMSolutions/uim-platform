/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.notifications;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.notification;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface NotificationRepository : ITenantRepository!(Notification, NotificationId) {

    size_t countByRecipient(TenantId tenantId, string recipientId);
    Notification[] findByRecipient(TenantId tenantId, string recipientId);
    void removeByRecipient(TenantId tenantId, string recipientId);

    size_t countByInstance(SituationInstanceId instanceId);
    Notification[] findByInstance(SituationInstanceId instanceId);
    void removeByInstance(SituationInstanceId instanceId);

    size_t countByStatus(TenantId tenantId, NotificationStatus status);
    Notification[] findByStatus(TenantId tenantId, NotificationStatus status);
    void removeByStatus(TenantId tenantId, NotificationStatus status);

}
