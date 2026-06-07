module uim.platform.management.presentation.rest.services.subscription;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
class SubscriptionApi : ISubscriptionApi {
    private ManageSubscriptionsUseCase usecase;

    this(ManageSubscriptionsUseCase usecase) {
        this.usecase = usecase;
    }

    override Subscription[] getSubscriptions(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override Subscription getSubscription(string tenantId, string id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, Subscription-ID: %s", tenantId, id);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return Subscription.init;
    }
}
///
unittest {
    // auto repo = new MemorySubscriptionRepository();
    // auto usecase = new ManageSubscriptionsUseCase(repo);
    // auto api = new SubscriptionApi(usecase);
    // 
    // string tenantId = "tenant-rest";
    // 
    // Test GET /rest/v1/subscriptions
    // auto subscriptions = api.getSubscriptions(tenantId);
    // assert(subscriptions is null); // Da wir noch keine Subscriptions erstellt haben
    // 
    // Test GET /rest/v1/subscriptions/:id
    // auto subscription = api.getSubscription(tenantId, "subscription-1");
    // assert(subscription == Subscription.init); // Da wir noch keine Subscription mit id "subscription-1" erstellt haben
}