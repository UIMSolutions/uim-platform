module uim.platform.management.infrastructure.persistence.memory.subscription_repo;

import uim.platform.management.domain.types;
import uim.platform.management.domain.entities.subscription;
import uim.platform.management.domain.ports.subscription_repository;

import std.algorithm : filter;
import std.array : array;

class MemorySubscriptionRepository : SubscriptionRepository
{
    private Subscription[SubscriptionId] store;

    Subscription findById(SubscriptionId id)
    {
        if (auto p = id in store)
            return *p;
        return Subscription.init;
    }

    Subscription[] findBySubaccount(SubaccountId subaccountId)
    {
        return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
    }

    Subscription[] findByApp(SubaccountId subaccountId, string appName)
    {
        return store.byValue()
            .filter!(e => e.subaccountId == subaccountId && e.appName == appName)
            .array;
    }

    Subscription[] findByStatus(SubaccountId subaccountId, SubscriptionStatus status)
    {
        return store.byValue()
            .filter!(e => e.subaccountId == subaccountId && e.status == status)
            .array;
    }

    void save(Subscription sub) { store[sub.id] = sub; }
    void update(Subscription sub) { store[sub.id] = sub; }
    void remove(SubscriptionId id) { store.remove(id); }
}
