module uim.platform.kyma.domain.ports.event_subscription_repository;

import uim.platform.kyma.domain.entities.event_subscription;
import uim.platform.kyma.domain.types;

/// Port: outgoing — event subscription persistence.
interface EventSubscriptionRepository
{
    EventSubscription findById(EventSubscriptionId id);
    EventSubscription findByName(NamespaceId nsId, string name);
    EventSubscription[] findByNamespace(NamespaceId nsId);
    EventSubscription[] findByEnvironment(KymaEnvironmentId envId);
    EventSubscription[] findBySource(string source);
    EventSubscription[] findByStatus(SubscriptionStatus status);
    void save(EventSubscription sub);
    void update(EventSubscription sub);
    void remove(EventSubscriptionId id);
}
