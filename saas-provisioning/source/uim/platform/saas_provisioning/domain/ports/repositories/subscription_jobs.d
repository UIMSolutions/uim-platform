/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.ports.repositories.subscription_jobs;

import uim.platform.saas_provisioning;

// mixin(ShowModule!());

@safe:

/// Port: persistence contract for the SubscriptionJob aggregate.
interface SubscriptionJobRepository : ITenantRepository!(SubscriptionJob, SubscriptionJobId) {
    /// Retrieve all jobs associated with a given subscription record.
    SubscriptionJob[] findBySubscription(TenantId tenantId, string subscriptionId);
}
