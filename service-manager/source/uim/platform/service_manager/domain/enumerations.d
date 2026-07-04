module uim.platform.service_manager.domain.enumerations;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Type of registered platform/environment
enum PlatformType {
    cloudFoundry,
    kubernetes,
    kyma,
    neo,
    other
}

/// Status of a registered platform
enum PlatformStatus {
    active,
    inactive,
    suspended
}

/// Status of a service broker
enum ServiceBrokerStatus {
    active,
    inactive,
    registrationFailed
}

/// Catalog status for a service offering
enum ServiceOfferingStatus {
    available,
    deprecated_,
    removed
}

/// Whether a service plan is free or paid
enum ServicePlanPricing {
    free,
    paid,
    beta
}

/// Status of a service instance
enum ServiceInstanceStatus {
    creating,
    created,
    updating,
    deleting,
    failed,
    orphaned
}

/// Status of a service binding
enum ServiceBindingStatus {
    creating,
    created,
    deleting,
    failed
}

/// Type of async operation
enum OperationType {
    create,
    update,
    delete_,
    bind,
    unbind
}

/// Status of an async operation
enum OperationStatus {
    pending,
    inProgress,
    succeeded,
    failed
}

/// Category of a service offering
enum ServiceCategory {
    platform,
    application,
    integration,
    data,
    security,
    ai,
    other
}
