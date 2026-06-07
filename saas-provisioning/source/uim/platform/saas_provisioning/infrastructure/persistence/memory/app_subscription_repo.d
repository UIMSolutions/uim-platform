/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.infrastructure.persistence.memory.app_subscription_repo;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

@safe:

/// In-memory implementation of AppSubscriptionRepository.
class MemoryAppSubscriptionRepository
    : TenantRepository!(AppSubscription, AppSubscriptionId),
      AppSubscriptionRepository
{
    AppSubscription[] findByAppName(TenantId tenantId, string appName) {
        AppSubscription[] result;
        foreach (sub; findByTenant(tenantId)) {
            if (sub.appName == appName) result ~= sub;
        }
        return result;
    }

    AppSubscription[] findBySubscriberTenant(TenantId tenantId, string subscriberTenantId) {
        AppSubscription[] result;
        foreach (sub; findByTenant(tenantId)) {
            if (sub.subscriberTenantId == subscriberTenantId) result ~= sub;
        }
        return result;
    }
}
