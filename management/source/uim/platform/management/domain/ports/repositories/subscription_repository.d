module uim.platform.management.domain.ports.subscription_repository;

import uim.platform.management.domain.entities.subscription;
import uim.platform.management.domain.types;

/// Port: outgoing — subscription persistence.
interface SubscriptionRepository {
    Subscription findById(SubscriptionId id);
    Subscription[] findBySubaccount(SubaccountId subaccountId);
    Subscription[] findByApp(SubaccountId subaccountId, string appName);
    Subscription[] findByStatus(SubaccountId subaccountId, SubscriptionStatus status);
    void save(Subscription sub);
    void update(Subscription sub);
    void remove(SubscriptionId id);
}
