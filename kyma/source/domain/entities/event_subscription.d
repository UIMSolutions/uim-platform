module uim.platform.xyz.domain.entities.event_subscription;

import domain.types;

/// An event subscription — subscribes to events from a source.
struct EventSubscription
{
    EventSubscriptionId id;
    NamespaceId namespaceId;
    KymaEnvironmentId environmentId;
    TenantId tenantId;
    string name;
    string description;
    SubscriptionStatus status = SubscriptionStatus.pending;

    // Event source
    string source;
    string[] eventTypes;
    EventTypeEncoding typeEncoding = EventTypeEncoding.exact;

    // Sink — the target to deliver events to
    string sinkUrl;
    string sinkServiceName;
    int sinkServicePort;

    // Configuration
    int maxInFlightMessages = 10;
    bool exactTypeMatching = true;

    // Filters
    string[string] filterAttributes;

    // Labels
    string[string] labels;

    // Metadata
    string createdBy;
    long createdAt;
    long modifiedAt;
}
