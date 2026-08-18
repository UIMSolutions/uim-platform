/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.application.usecases.manage.app_subscriptions;

import uim.platform.saas_provisioning;



mixin(ShowModule!());

@safe:

/// Use case: provider-view subscription management — all subscriptions for a given application.
class ManageAppSubscriptionsUseCase {
    private AppSubscriptionRepository subRepo;
    private SubscriptionEngine        engine;

    this(AppSubscriptionRepository subRepo, SubscriptionEngine engine) {
        this.subRepo = subRepo;
        this.engine  = engine;
    }

    AppSubscription[] listForApp(TenantId tenantId, string appName) {
        return subRepo.findByAppName(tenantId, appName);
    }

    AppSubscription[] listAll(TenantId tenantId) {
        return subRepo.findByTenant(tenantId);
    }

    AppSubscription getSubscription(TenantId tenantId, AppSubscriptionId id) {
        return subRepo.findById(tenantId, id);
    }

    /// Subscribe a consumer tenant to an application via the SubscriptionEngine.
    UsecaseResult subscribeConsumer(TenantId tenantId, string appName, SubscribeRequest req) {
        auto job = engine.beginSubscribe(tenantId, appName,
                                         req.subscriberTenantId,
                                         req.subdomain,
                                         req.subscribedBy);
        if (job.isNull) return UsecaseResult(false, "", "Application not found");
        return UsecaseResult(true, job.subscriptionId, "");
    }

    /// Unsubscribe a consumer tenant from an application.
    UsecaseResult unsubscribeConsumer(TenantId tenantId, AppSubscriptionId id, UserId requestedBy) {
        auto job = engine.beginUnsubscribe(tenantId, id.value, requestedBy);
        if (job.isNull) return UsecaseResult(false, "", "Subscription not found");
        return UsecaseResult(true, id.value, "");
    }

    UsecaseResult updateSubscription(TenantId tenantId, AppSubscriptionId id,
                                      UpdateSubscriptionRequest req) {
        auto sub = subRepo.findById(tenantId, id);
        if (sub.isNull) return UsecaseResult(false, "", "Subscription not found");

        long now  = MonoTime.currTime.ticks;
        sub.state     = req.state;
        sub.error     = req.error;
        sub.updatedAt = now;
        subRepo.update(sub);
        return UsecaseResult(true, id.value, "");
    }
}
