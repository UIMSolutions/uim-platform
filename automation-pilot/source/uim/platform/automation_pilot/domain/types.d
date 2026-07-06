module uim.platform.automation_pilot.domain.types;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct CatalogId {
    mixin(IdTemplate);
}

struct CommandId {
    mixin(IdTemplate);
}

struct CommandInputId {
    mixin(IdTemplate);
}

struct ExecutionId {
    mixin(IdTemplate);
}

struct ScheduledExecutionId {
    mixin(IdTemplate);
}

struct TriggerId {
    mixin(IdTemplate);
}

struct ServiceAccountId {
    mixin(IdTemplate);
}

struct ContentConnectorId {
    mixin(IdTemplate);
}
