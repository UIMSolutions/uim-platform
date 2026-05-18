/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.services.subscription_engine;

import uim.platform.saas_provisioning;
import core.time : MonoTime;
import std.conv : to;
import std.array : replace;

mixin(ShowModule!());

@safe:

/// Domain service — orchestrates the subscribe / unsubscribe / update lifecycle.
///
/// In production this service would invoke the application's onSubscriptionUrl
/// callback asynchronously. The current implementation is a synchronous stub
/// that transitions state immediately.
class SubscriptionEngine {
    private SaasApplicationRepository  appRepo;
    private AppSubscriptionRepository  subRepo;
    private SubscriptionJobRepository  jobRepo;

    this(SaasApplicationRepository appRepo,
         AppSubscriptionRepository subRepo,
         SubscriptionJobRepository jobRepo) {
        this.appRepo = appRepo;
        this.subRepo = subRepo;
        this.jobRepo = jobRepo;
    }

    // -----------------------------------------------------------------------
    // Subscribe
    // -----------------------------------------------------------------------

    /// Begin an async subscribe operation; returns the created SubscriptionJob.
    /// Returns a null job (isNull == true) when the application does not exist.
    SubscriptionJob beginSubscribe(string providerTenantId,
                                   string appName,
                                   string subscriberTenantId,
                                   string subdomain,
                                   string subscribedBy) {
        auto app = appRepo.findByAppName(providerTenantId, appName);
        if (app.isNull) return new SubscriptionJob();

        long now    = MonoTime.currTime.ticks;
        string subId = now.to!string ~ "-sub-" ~ appName;
        string jobId = now.to!string ~ "-job-subscribe";

        auto sub = new AppSubscription();
        sub.id                        = AppSubscriptionId(subId);
        sub.tenantId                  = providerTenantId;
        sub.appName                   = appName;
        sub.appDisplayName            = app.displayName;
        sub.subscriberTenantId        = subscriberTenantId;
        sub.subdomain                 = subdomain;
        sub.subscribedBy              = subscribedBy;
        sub.state                     = SubscriptionState.subscribing;
        sub.createdAt                 = now;
        sub.updatedAt                 = now;
        subRepo.add(sub);

        auto job = new SubscriptionJob();
        job.id             = SubscriptionJobId(jobId);
        job.tenantId       = providerTenantId;
        job.appName        = appName;
        job.subscriptionId = subId;
        job.jobType        = JobType.subscribe;
        job.jobStatus      = JobStatus.succeeded; // stub: immediate success
        job.progress       = 100;
        job.message        = "Subscription created (stub — no callback invoked)";
        job.startedAt      = now;
        job.finishedAt     = now;
        job.createdAt      = now;
        job.updatedAt      = now;
        jobRepo.add(job);

        // Transition subscription to subscribed immediately (stub)
        sub.state      = SubscriptionState.subscribed;
        sub.jobId      = jobId;
        sub.consumerUrl = resolveConsumerUrl(app.appUrls.appBaseUrl, subdomain);
        sub.updatedAt  = now;
        subRepo.update(sub);

        return job;
    }

    // -----------------------------------------------------------------------
    // Unsubscribe
    // -----------------------------------------------------------------------

    SubscriptionJob beginUnsubscribe(string providerTenantId,
                                      string subscriptionId,
                                      string requestedBy) {
        auto sub = subRepo.findById(providerTenantId, AppSubscriptionId(subscriptionId));
        if (sub.isNull) return new SubscriptionJob();

        long now     = MonoTime.currTime.ticks;
        string jobId  = now.to!string ~ "-job-unsubscribe";

        auto job = new SubscriptionJob();
        job.id             = SubscriptionJobId(jobId);
        job.tenantId       = providerTenantId;
        job.appName        = sub.appName;
        job.subscriptionId = subscriptionId;
        job.jobType        = JobType.unsubscribe;
        job.jobStatus      = JobStatus.succeeded;
        job.progress       = 100;
        job.message        = "Unsubscription completed (stub — no callback invoked)";
        job.startedAt      = now;
        job.finishedAt     = now;
        job.createdAt      = now;
        job.updatedAt      = now;
        jobRepo.add(job);

        sub.state     = SubscriptionState.unsubscribed;
        sub.jobId     = jobId;
        sub.updatedAt = now;
        subRepo.update(sub);

        return job;
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private string resolveConsumerUrl(string template_, string subdomain) {
        return template_.replace("{subdomain}", subdomain);
    }
}
