module uim.platform.event_mesh.domain.types;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

// --- ID Aliases ---
struct BrokerServiceId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct QueueId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TopicId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct EventSubscriptionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct EventMessageId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct EventSchemaId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct EventApplicationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct MeshBridgeId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
