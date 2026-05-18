/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.saas_provisioning.domain.ports.repositories.app_subscriptions;

import uim.platform.saas_provisioning;

mixin(ShowModule!());

@safe:

/// Port: persistence contract for the AppSubscription aggregate root.
interface AppSubscriptionRepository : ITenantRepository!(AppSubscription, AppSubscriptionId) {
    /// List all subscriptions to a specific application (provider view).
    AppSubscription[] findByAppName(string tenantId, string appName);

    /// List all subscriptions for a specific consumer tenant (consumer view).
    AppSubscription[] findBySubscriberTenant(string tenantId, string subscriberTenantId);
}
