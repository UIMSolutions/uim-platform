/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.infrastructure.persistence.memory.mta_subscription_repo;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

class MemoryMtaSubscriptionRepository
    : TenantRepository!(MtaSubscription, MtaSubscriptionId),
      MtaSubscriptionRepository
{
    /// Find all subscriptions for a given provider MTA ID
    MtaSubscription[] findByProviderMtaId(TenantId tenantId, string mtaId) {
        MtaSubscription[] result;
        foreach (s; findByTenant(tenantId))
            if (s.mtaId == mtaId) result ~= s;
        return result;
    }
}
