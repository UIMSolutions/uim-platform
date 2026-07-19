module uim.platform.event_mesh.domain.types;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

/// Strongly-typed identifier for a BrokerService aggregate root.
struct BrokerServiceId {
    mixin(IdTemplate());
}

/// Strongly-typed identifier for a Queue aggregate root.
struct QueueId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Topic aggregate root.
struct TopicId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a Subscription aggregate root.
struct SubscriptionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an EventSubscription aggregate root.
struct EventSubscriptionId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an EventMessage aggregate root.
struct EventMessageId {
    mixin(IdTemplate);
}   

/// Strongly-typed identifier for an EventSchema aggregate root.
struct EventSchemaId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for an EventApplication aggregate root.
struct EventApplicationId {
    mixin(IdTemplate);
}

/// Strongly-typed identifier for a MeshBridge aggregate root.
struct MeshBridgeId {
    mixin(IdTemplate);
}
