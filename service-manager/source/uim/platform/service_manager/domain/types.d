module uim.platform.service_manager.domain.types;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct PlatformId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ServiceBrokerId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ServiceOfferingId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ServicePlanId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ServiceInstanceId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ServiceBindingId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct OperationId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct LabelId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
