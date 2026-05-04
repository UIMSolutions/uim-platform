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

private static CheckType parseCheckType(string checkType) {
    switch (checkType) {
    case "jmx":
        return CheckType.jmx;
    case "customHttp":
        return CheckType.customHttp;
    case "process":
        return CheckType.process;
    case "database":
        return CheckType.database;
    case "certificate":
        return CheckType.certificate;
    default:
        return CheckType.availability;
    }
}

private static CheckStatus parseCheckStatus(string s) {
    switch (s) {
    case "ok":
        return CheckStatus.ok;
    case "warning":
        return CheckStatus.warning;
    case "critical":
        return CheckStatus.critical;
    case "disabled":
        return CheckStatus.disabled;
    default:
        return CheckStatus.unknown;
    }
}

private static ThresholdOperator parseThresholdOperator(string s) {
    switch (s) {
    case "greaterOrEqual":
        return ThresholdOperator.greaterOrEqual;
    case "lessThan":
        return ThresholdOperator.lessThan;
    case "lessOrEqual":
        return ThresholdOperator.lessOrEqual;
    case "equal":
        return ThresholdOperator.equal;
    case "notEqual":
        return ThresholdOperator.notEqual;
    default:
        return ThresholdOperator.greaterThan;
    }
}

private static ChannelState parseChannelState(string state) {
    switch (state) {
    case "inactive":
        return ChannelState.inactive;
    case "error":
        return ChannelState.error;
    default:
        return ChannelState.active;
    }
}
