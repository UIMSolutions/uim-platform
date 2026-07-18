/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.infrastructure.persistence.repositories.subscription_job_repo;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

/// In-memory implementation of SubscriptionJobRepository.
class MemorySubscriptionJobRepository
    : TenantRepository!(SubscriptionJob, SubscriptionJobId),
      SubscriptionJobRepository
{
    SubscriptionJob[] findBySubscription(TenantId tenantId, string subscriptionId) {
        SubscriptionJob[] result;
        foreach (job; findByTenant(tenantId)) {
            if (job.subscriptionId == subscriptionId) result ~= job;
        }
        return result;
    }
}
