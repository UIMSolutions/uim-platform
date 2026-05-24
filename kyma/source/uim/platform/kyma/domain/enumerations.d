module uim.platform.kyma.domain.enumerations;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Status of a Kyma environment/cluster.
enum EnvironmentStatus {
    provisioning,
    running,
    updating,
    stopping,
    stopped,
    deprovisioning,
    error,
}
EnvironmentStatus toEnvironmentStatus(string s) {
    switch (s.toLower()) {
        case "provisioning": return EnvironmentStatus.provisioning;
        case "running": return EnvironmentStatus.running;
        case "updating": return EnvironmentStatus.updating;
        case "stopping": return EnvironmentStatus.stopping;
        case "stopped": return EnvironmentStatus.stopped;
        case "deprovisioning": return EnvironmentStatus.deprovisioning;
        case "error": return EnvironmentStatus.error;
        default: return EnvironmentStatus.error; // default
    }
}

/// Kyma plan / machine type.
enum KymaPlan {
    azure,
    aws,
    gcp,
    sapConvergedCloud,
    free_,
    trial,
}
KymaPlan toKymaPlan(string s) {
    switch (s.toLower()) {
        case "azure": return KymaPlan.azure;
        case "aws": return KymaPlan.aws;
        case "gcp": return KymaPlan.gcp;
        case "sapconvergedcloud": return KymaPlan.sapConvergedCloud;
        case "free": return KymaPlan.free_;
        case "trial": return KymaPlan.trial;
        default: return KymaPlan.free_; // default
    }
}

/// Status of a Kubernetes namespace.
enum NamespaceStatus {
    active,
    terminating,
}
NamespaceStatus toNamespaceStatus(string s) {
    switch (s.toLower()) {
        case "active": return NamespaceStatus.active;
        case "terminating": return NamespaceStatus.terminating;
        default: return NamespaceStatus.active; // default
    }
}

/// Serverless function runtime language.
enum FunctionRuntime {
    nodejs20,
    nodejs18,
    python39,
    python312,
}

FunctionRuntime toFunctionRuntime(string s) {
    switch (s.toLower()) {
        case "nodejs20": return FunctionRuntime.nodejs20;
        case "nodejs18": return FunctionRuntime.nodejs18;
        case "python39": return FunctionRuntime.python39;
        case "python312": return FunctionRuntime.python312;
        default: return FunctionRuntime.nodejs20; // default
    }
}

/// Status of a serverless function.
enum FunctionStatus {
    building,
    deploying,
    running,
    error,
    inactive,
}
FunctionStatus toFunctionStatus(string s) {
    switch (s.toLower()) {
        case "building": return FunctionStatus.building;
        case "deploying": return FunctionStatus.deploying;
        case "running": return FunctionStatus.running;
        case "error": return FunctionStatus.error;
        case "inactive": return FunctionStatus.inactive;
        default: return FunctionStatus.error; // default
    }
}   

/// Scaling type for serverless functions.
enum ScalingType {
    auto_,
    fixed,
}
ScalingType toScalingType(string s) {
    switch (s.toLower()) {
        case "fixed": return ScalingType.fixed;
        case "auto": return ScalingType.auto_;
        default: return ScalingType.auto_; // default
    }
}

/// API rule access strategy.
enum AccessStrategy {
    noAuth,
    oauth2Introspection,
    jwt,
    allowAll,
}
AccessStrategy toAccessStrategy(string s) {
    switch (s.toLower()) {
        case "noauth": return AccessStrategy.noAuth;
        case "oauth2introspection": return AccessStrategy.oauth2Introspection;
        case "jwt": return AccessStrategy.jwt;
        case "allowall": return AccessStrategy.allowAll;
        default: return AccessStrategy.noAuth; // default
    }
}

/// API rule status.
enum ApiRuleStatus {
    ok,
    error,
    notReady,
}

ApiRuleStatus toApiRuleStatus(string s) {
    switch (s.toLower) {
        case "ok": return ApiRuleStatus.ok;
        case "error": return ApiRuleStatus.error;
        case "notready": return ApiRuleStatus.notReady;
        default: return ApiRuleStatus.error; // default
    }
}

/// HTTP methods for API rules.
enum ApiHttpMethod : string {
    get_ = "GET",
    post_ = "POST",
    put_ = "PUT",
    patch_ = "PATCH",
    delete_ = "DELETE",
    head_ = "HEAD",
    options_ = "OPTIONS",
}

ApiHttpMethod toApiHttpMethod(string s) {
    switch (s.toUpper) {
        case "GET": return ApiHttpMethod.get_;
        case "POST": return ApiHttpMethod.post_;
        case "PUT": return ApiHttpMethod.put_;
        case "PATCH": return ApiHttpMethod.patch_;
        case "DELETE": return ApiHttpMethod.delete_;
        case "HEAD": return ApiHttpMethod.head_;
        case "OPTIONS": return ApiHttpMethod.options_;
        default: return ApiHttpMethod.get_; // default
    }
}
/// Status of a service instance.
enum ServiceInstanceStatus {
    creating,
    ready,
    failed,
    deleting,
    updating,
}
ServiceInstanceStatus toServiceInstanceStatus(string s) {
    switch (s.toLower()) {
        case "creating": return ServiceInstanceStatus.creating;
        case "ready": return ServiceInstanceStatus.ready;
        case "failed": return ServiceInstanceStatus.failed;
        case "deleting": return ServiceInstanceStatus.deleting;
        case "updating": return ServiceInstanceStatus.updating;
        default: return ServiceInstanceStatus.failed; // default
    }
}
/// Status of a service binding.
/// Status of a service binding.
enum ServiceBindingStatus {
    creating,
    ready,
    failed,
    deleting,
}
ServiceBindingStatus toServiceBindingStatus(string s) {
    switch (s.toLower()) {
        case "creating": return ServiceBindingStatus.creating;
        case "ready": return ServiceBindingStatus.ready;
        case "failed": return ServiceBindingStatus.failed;
        case "deleting": return ServiceBindingStatus.deleting;
        default: return ServiceBindingStatus.failed; // default
    }
}
/// Event type encoding.
enum EventTypeEncoding {
    exact,
    prefix,
}
EventTypeEncoding toEventTypeEncoding(string s) {
    switch (s.toLower()) {
        case "exact": return EventTypeEncoding.exact;
        case "prefix": return EventTypeEncoding.prefix;
        default: return EventTypeEncoding.exact; // default
    }
}
/// Status of an event subscription.
enum SubscriptionStatus {
    active,
    pending,
    error,
    paused,
}
SubscriptionStatus toSubscriptionStatus(string s) {
    switch (s.toLower()) {
        case "active": return SubscriptionStatus.active;
        case "pending": return SubscriptionStatus.pending;
        case "error": return SubscriptionStatus.error;
        case "paused": return SubscriptionStatus.paused;
        default: return SubscriptionStatus.error; // default
    }
}

/// Kyma module status.
enum ModuleStatus {
    enabled,
    disabled,
    installing,
    uninstalling,
    error,
    warning_,
}
ModuleStatus toModuleStatus(string s) {
    switch (s.toLower()) {
        case "enabled": return ModuleStatus.enabled;
        case "disabled": return ModuleStatus.disabled;
        case "installing": return ModuleStatus.installing;
        case "uninstalling": return ModuleStatus.uninstalling;
        case "error": return ModuleStatus.error;
        case "warning": return ModuleStatus.warning_;
        default: return ModuleStatus.error; // default
    }   
}
/// Known Kyma module types.
enum ModuleType : string {
    istio = "istio",
    apiGateway = "api-gateway",
    serverless = "serverless",
    eventing = "eventing",
    nats = "nats",
    telemetry = "telemetry",
    btp_operator = "btp-operator",
    keda = "keda",
    connectivityProxy = "connectivity-proxy",
    custom = "custom",
}
ModuleType toModuleType(string s) {
    switch (s.toLower()) {
        case "istio": return ModuleType.istio;
        case "apigateway": return ModuleType.apiGateway;
        case "serverless": return ModuleType.serverless;
        case "eventing": return ModuleType.eventing;
        case "nats": return ModuleType.nats;
        case "telemetry": return ModuleType.telemetry;
        case "btpoperator": return ModuleType.btp_operator;
        case "keda": return ModuleType.keda;
        case "connectivityproxy": return ModuleType.connectivityProxy;
        case "custom": return ModuleType.custom;
        default: return ModuleType.custom; // default
    }
}

/// Application connectivity status.
enum AppConnectivityStatus {
    connected,
    disconnected,
    pairing,
    error,
}
AppConnectivityStatus toAppConnectivityStatus(string s) {
    switch (s.toLower()) {
        case "connected": return AppConnectivityStatus.connected;
        case "disconnected": return AppConnectivityStatus.disconnected;
        case "pairing": return AppConnectivityStatus.pairing;
        case "error": return AppConnectivityStatus.error;
        default: return AppConnectivityStatus.error; // default
    }
}
/// Application registration type.
enum AppRegistrationType {
    api,
    events,
    apiAndEvents,
}
AppRegistrationType toAppRegistrationType(string s) {
    switch (s.toLower()) {
        case "api": return AppRegistrationType.api;
        case "events": return AppRegistrationType.events;
        case "apiandevents": return AppRegistrationType.apiAndEvents;
        default: return AppRegistrationType.api; // default
    }
}
/// Resource quota enforcement level.
enum QuotaEnforcement {
    enforce,
    warn_,
    none,
}
QuotaEnforcement toQuotaEnforcement(string s) {
    switch (s.toLower()) {
        case "enforce": return QuotaEnforcement.enforce;
        case "warn": return QuotaEnforcement.warn_;
        case "none": return QuotaEnforcement.none;
        default: return QuotaEnforcement.none; // default
    }
}
