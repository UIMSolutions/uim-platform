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
/// Kyma plan / machine type.
enum KymaPlan {
    azure,
    aws,
    gcp,
    sapConvergedCloud,
    free_,
    trial,
}
/// Status of a Kubernetes namespace.
enum NamespaceStatus {
    active,
    terminating,
}
/// Serverless function runtime language.
enum FunctionRuntime {
    nodejs20,
    nodejs18,
    python39,
    python312,
}

/// Status of a serverless function.
enum FunctionStatus {
    building,
    deploying,
    running,
    error,
    inactive,
}
/// Scaling type for serverless functions.
enum ScalingType {
    fixed,
    auto_,
}
/// API rule access strategy.
enum AccessStrategy {
    noAuth,
    oauth2Introspection,
    jwt,
    allowAll,
}
/// API rule status.
enum ApiRuleStatus {
    ok,
    error,
    notReady,
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
/// Status of a service instance.
enum ServiceInstanceStatus {
    creating,
    ready,
    failed,
    deleting,
    updating,
}
/// Status of a service binding.
enum ServiceBindingStatus {
    creating,
    ready,
    failed,
    deleting,
}
/// Event type encoding.
enum EventTypeEncoding {
    exact,
    prefix,
}
/// Status of an event subscription.
enum SubscriptionStatus {
    active,
    pending,
    error,
    paused,
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
/// Application connectivity status.
enum AppConnectivityStatus {
    connected,
    disconnected,
    pairing,
    error,
}
/// Application registration type.
enum AppRegistrationType {
    api,
    events,
    apiAndEvents,
}
/// Resource quota enforcement level.
enum QuotaEnforcement {
    enforce,
    warn_,
    none,
}
