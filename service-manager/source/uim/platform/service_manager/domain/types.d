module uim.platform.service_manager.domain.types;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct PlatformId {
    mixin(IdTemplate);
}

struct ServiceBrokerId {
    mixin(IdTemplate);
}

struct ServiceOfferingId {
    mixin(IdTemplate);
}

struct ServicePlanId {
    mixin(IdTemplate);
}

struct OperationId {
    mixin(IdTemplate);
}

struct LabelId {
    mixin(IdTemplate);
}
