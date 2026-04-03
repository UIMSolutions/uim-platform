module uim.platform.xyz.infrastructure.persistence.memory.event_subscription_repo;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.event_subscription;
import uim.platform.xyz.domain.ports.event_subscription_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryEventSubscriptionRepository : EventSubscriptionRepository
{
    private EventSubscription[EventSubscriptionId] store;

    EventSubscription findById(EventSubscriptionId id)
    {
        if (auto p = id in store)
            return *p;
        return EventSubscription.init;
    }

    EventSubscription findByName(NamespaceId nsId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.namespaceId == nsId && e.name == name)
                return e;
        return EventSubscription.init;
    }

    EventSubscription[] findByNamespace(NamespaceId nsId)
    {
        return store.byValue().filter!(e => e.namespaceId == nsId).array;
    }

    EventSubscription[] findByEnvironment(KymaEnvironmentId envId)
    {
        return store.byValue().filter!(e => e.environmentId == envId).array;
    }

    EventSubscription[] findBySource(string source)
    {
        return store.byValue().filter!(e => e.source == source).array;
    }

    EventSubscription[] findByStatus(SubscriptionStatus status)
    {
        return store.byValue().filter!(e => e.status == status).array;
    }

    void save(EventSubscription sub) { store[sub.id] = sub; }
    void update(EventSubscription sub) { store[sub.id] = sub; }
    void remove(EventSubscriptionId id) { store.remove(id); }
}
