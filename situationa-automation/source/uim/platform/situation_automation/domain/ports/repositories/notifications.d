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

interface NotificationRepository {
    Notification findById(NotificationId id);
    Notification[] findByTenant(TenantId tenantId);
    Notification[] findByRecipient(TenantId tenantId, string recipientId);
    Notification[] findByInstance(SituationInstanceId instanceId);
    Notification[] findByStatus(TenantId tenantId, NotificationStatus status);
    void save(Notification n);
    void update(Notification n);
    void remove(NotificationId id);
    long countByTenant(TenantId tenantId);
}
