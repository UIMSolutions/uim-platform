module uim.platform.event_mesh.domain.types;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:
// --- ID Aliases ---
struct BrokerServiceId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct QueueId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct TopicId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct EventSubscriptionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct EventMessageId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct EventSchemaId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct EventApplicationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct MeshBridgeId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
