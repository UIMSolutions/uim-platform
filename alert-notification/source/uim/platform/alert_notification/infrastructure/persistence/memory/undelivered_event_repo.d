/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.infrastructure.persistence.memory.undelivered_event_repo;

import uim.platform.alert_notification;

// mixin(ShowModule!());

@safe:

class MemoryUndeliveredEventRepository
    : TentRepository!(UndeliveredEvent, UndeliveredEventId),
      UndeliveredEventRepository
{
    UndeliveredEvent[] findBySubscription(TenantId tenantId, string subscriptionName) {
        UndeliveredEvent[] result;
        foreach (e; findByTenant(tenantId))
            if (e.subscriptionName == subscriptionName) result ~= e;
        return result;
    }
}
