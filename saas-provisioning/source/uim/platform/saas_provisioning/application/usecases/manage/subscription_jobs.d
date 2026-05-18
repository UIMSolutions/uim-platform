/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.application.usecases.manage.subscription_jobs;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

/// Use case: query subscription job status (poll endpoint for async operations).
class ManageSubscriptionJobsUseCase {
    private SubscriptionJobRepository repo;

    this(SubscriptionJobRepository repo) {
        this.repo = repo;
    }

    SubscriptionJob[] listJobs(string tenantId) {
        return repo.findByTenant(tenantId);
    }

    SubscriptionJob getJob(string tenantId, SubscriptionJobId id) {
        return repo.findById(tenantId, id);
    }

    SubscriptionJob[] listJobsForSubscription(string tenantId, string subscriptionId) {
        return repo.findBySubscription(tenantId, subscriptionId);
    }
}
