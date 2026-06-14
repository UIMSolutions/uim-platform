module uim.platform.automation_pilot.domain.types;

import uim.platform.automation_pilot;

// mixin(ShowModule!());

@safe:

struct CatalogId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct CommandId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct CommandInputId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ExecutionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ScheduledExecutionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct TriggerId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ServiceAccountId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ContentConnectorId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
