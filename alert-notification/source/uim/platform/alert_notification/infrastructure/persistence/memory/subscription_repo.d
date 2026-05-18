/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.alert_notification.infrastructure.persistence.memory.subscription_repo;

import uim.platform.alert_notification;

mixin(ShowModule!());

@safe:

class MemorySubscriptionRepository
    : TenantRepository!(Subscription, SubscriptionId),
      SubscriptionRepository
{
    Subscription findByName(string tenantId, string name) {
        foreach (s; findAll(tenantId))
            if (s.name == name) return s;
        auto empty = new Subscription();
        return empty;
    }

    Subscription[] findEnabled(string tenantId) {
        Subscription[] result;
        foreach (s; findAll(tenantId))
            if (s.isEnabled()) result ~= s;
        return result;
    }
}
