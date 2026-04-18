module uim.platform.service_manager.domain.types;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct PlatformId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ServiceBrokerId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ServiceOfferingId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ServicePlanId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ServiceInstanceId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct ServiceBindingId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct OperationId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct LabelId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}
