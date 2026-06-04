module uim.platform.management.presentation.rest.interfaces.subscription;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface ISubscriptionApi {
    // GET /rest/v1/subscriptions
    @headerParam("tenantId", "X-Tenant-ID")
    Subscription[] getSubscriptions(string tenantId);

    // GET /rest/v1/subscriptions/:id
    @headerParam("tenantId", "X-Tenant-ID")
    Subscription getSubscription(string tenantId, string id);
}