module uim.platform.automation_pilot.domain.types;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct CatalogId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct CommandId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct CommandInputId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ExecutionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ScheduledExecutionId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct TriggerId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ServiceAccountId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct ContentConnectorId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
