module uim.platform.management.presentation.rest.interfaces.subscription;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface ISubscriptionApi {
    // GET /rest/v1/subscriptions
    Subscription[] getSubscriptions();

    // GET /rest/v1/subscriptions/:id
    Subscription getSubscription(string id);
}