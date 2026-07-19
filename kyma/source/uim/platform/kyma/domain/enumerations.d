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
EnvironmentStatus toEnvironmentStatus(string value) {
    mixin(EnumSwitch!"EnvironmentStatus", "error");
}
EnvironmentStatus[] toEnvironmentStatuses(string[] values) {
    return values.map!(v => toEnvironmentStatus(v)).array;
}
string toString(EnvironmentStatus value) {
    return value.to!string;
}
string[] toStrings(EnvironmentStatus[] values) {
    return values.map!(v => toString(v)).array;
}
///
unittest {
    mixin(ShowTest!"EnvironmentStatus");

    assert("provisioning".toEnvironmentStatus == EnvironmentStatus.provisioning);
    assert("running".toEnvironmentStatus == EnvironmentStatus.running);        
    assert("updating".toEnvironmentStatus == EnvironmentStatus.updating);
    assert("stopping".toEnvironmentStatus == EnvironmentStatus.stopping);
    assert("stopped".toEnvironmentStatus == EnvironmentStatus.stopped);
    assert("deprovisioning".toEnvironmentStatus == EnvironmentStatus.deprovisioning);
    assert("error".toEnvironmentStatus == EnvironmentStatus.error);    

    assert("".toEnvironmentStatus == EnvironmentStatus.error); // Default value for unknown strings is "error"
    assert("unknown".toEnvironmentStatus == EnvironmentStatus.error); // Default value for unknown strings

    assert(EnvironmentStatus.provisioning.toString == "provisioning");
    assert(EnvironmentStatus.running.toString == "running");   
    assert(EnvironmentStatus.updating.toString == "updating");
    assert(EnvironmentStatus.stopping.toString == "stopping");
    assert(EnvironmentStatus.stopped.toString == "stopped");
    assert(EnvironmentStatus.deprovisioning.toString == "deprovisioning");
    assert(EnvironmentStatus.error.toString == "error");   

    assert(toStringArray([EnvironmentStatus.provisioning, EnvironmentStatus.running, EnvironmentStatus.updating, EnvironmentStatus.stopping, EnvironmentStatus.stopped, EnvironmentStatus.deprovisioning, EnvironmentStatus.error]) == ["provisioning", "running", "updating", "stopping", "stopped", "deprovisioning", "error"]);
    assert(toEnvironmentStatusArray(["provisioning", "running", "updating", "stopping", "stopped", "deprovisioning", "error"]) == [EnvironmentStatus.provisioning, EnvironmentStatus.running, EnvironmentStatus.updating, EnvironmentStatus.stopping, EnvironmentStatus.stopped, EnvironmentStatus.deprovisioning, EnvironmentStatus.error]);
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
KymaPlan toKymaPlan(string value) {
    mixin(EnumSwitch!"KymaPlan", "free_");
}
KymaPlan[] toKymaPlan(string[] values) {
    return values.map!(v => toKymaPlan(v)).array;
}
string toString(KymaPlan value) {
    return value.to!string;
}
string[] toStrings(KymaPlan[] values) {
    return values.map!(v => toString(v)).array;
}
///
unittest {
    mixin(ShowTest!"KymaPlan");
    
    assert("azure".toKymaPlan == KymaPlan.azure);
    assert("aws".toKymaPlan == KymaPlan.aws);        
    assert("gcp".toKymaPlan == KymaPlan.gcp);
    assert("sapconvergedcloud".toKymaPlan == KymaPlan.sapConvergedCloud);
    assert("free".toKymaPlan == KymaPlan.free_);
    assert("trial".toKymaPlan == KymaPlan.trial);    

    assert("".toKymaPlan == KymaPlan.free_); // Default value for unknown strings is "free"
    assert("unknown".toKymaPlan == KymaPlan.free_); // Default value for unknown strings

    assert(KymaPlan.azure.toString == "azure");
    assert(KymaPlan.aws.toString == "aws");   
    assert(KymaPlan.gcp.toString == "gcp");
    assert(KymaPlan.sapConvergedCloud.toString == "sapConvergedCloud");
    assert(KymaPlan.free_.toString == "free");
    assert(KymaPlan.trial.toString == "trial");   

    assert(toStringArray([KymaPlan.azure, KymaPlan.aws, KymaPlan.gcp, KymaPlan.sapConvergedCloud, KymaPlan.free_, KymaPlan.trial]) == ["azure", "aws", "gcp", "sapConvergedCloud", "free", "trial"]);
    assert(toKymaPlanArray(["azure", "aws", "gcp", "sapConvergedCloud", "free", "trial"]) == [KymaPlan.azure, KymaPlan.aws, KymaPlan.gcp, KymaPlan.sapConvergedCloud, KymaPlan.free_, KymaPlan.trial]);
}

/// Status of a Kubernetes namespace.
enum NamespaceStatus {
    active,
    terminating,
}
NamespaceStatus toNamespaceStatus(string value) {
    mixin(EnumSwitch!"NamespaceStatus", "active");
}
NamespaceStatus[] toNamespaceStatuses(string[] values) {
    return values.map!(v => toNamespaceStatus(v)).array;
}
string toString(NamespaceStatus value) {
    return value.to!string;
}
string[] toStrings(NamespaceStatus[] values) {   
    return values.map!(v => toString(v)).array;
}
///
unittest {
    mixin(ShowTest!"NamespaceStatus");

    assert("active".toNamespaceStatus == NamespaceStatus.active);
    assert("terminating".toNamespaceStatus == NamespaceStatus.terminating);

    assert("".toNamespaceStatus == NamespaceStatus.active); // Default value for unknown strings is "active"
    assert("unknown".toNamespaceStatus == NamespaceStatus.active); // Default value for unknown strings is "active"

    assert(NamespaceStatus.active.toString == "active");
    assert(NamespaceStatus.terminating.toString == "terminating");

    assert(toStringArray([NamespaceStatus.active, NamespaceStatus.terminating]) == ["active", "terminating"]);
    assert(toNamespaceStatusArray(["active", "terminating"]) == [NamespaceStatus.active, NamespaceStatus.terminating]);
}

/// Serverless function runtime language.
enum FunctionRuntime {
    nodejs20,
    nodejs18,
    python39,
    python312,
}

FunctionRuntime toFunctionRuntime(string value) {
    mixin(EnumSwitch!"FunctionRuntime", "nodejs20");
}
FunctionRuntime[] toFunctionRuntimeArray(string[] values) {
    return values.map!(v => toFunctionRuntime(v)).array;
}
string toString(FunctionRuntime value) {
    return value.to!string;
}
string[] toStringArray(FunctionRuntime[] values) {
    return values.map!(v => toString(v)).array;
}
///
unittest {
    mixin(ShowTest!"FunctionRuntime");

    assert("nodejs20".toFunctionRuntime == FunctionRuntime.nodejs20);
    assert("nodejs18".toFunctionRuntime == FunctionRuntime.nodejs18);
    assert("python39".toFunctionRuntime == FunctionRuntime.python39);
    assert("python312".toFunctionRuntime == FunctionRuntime.python312);

    assert("".toFunctionRuntime == FunctionRuntime.nodejs20); // Default value for unknown strings is "nodejs20"
    assert("unknown".toFunctionRuntime == FunctionRuntime.nodejs20); // Default value for unknown strings is "nodejs20"

    assert(toString(FunctionRuntime.nodejs20) == "nodejs20");
    assert(toString(FunctionRuntime.nodejs18) == "nodejs18");
    assert(toString(FunctionRuntime.python39) == "python39");
    assert(toString(FunctionRuntime.python312) == "python312");

    assert(toFunctionRuntimeArray(["nodejs20", "python39", "invalid"]) == [FunctionRuntime.nodejs20, FunctionRuntime.python39, FunctionRuntime.nodejs20]);
    assert(toStringArray([FunctionRuntime.nodejs20, FunctionRuntime.python312]) == ["nodejs20", "python312"]);
}

/// Status of a serverless function.
enum FunctionStatus {
    building,
    deploying,
    running,
    error,
    inactive,
}
FunctionStatus toFunctionStatus(string value) {
    mixin(EnumSwitch!"FunctionStatus", "error");
}   
FunctionStatus[] toFunctionStatuses(string[] values) {
    return values.map!(v => toFunctionStatus(v)).array;
}
string toString(FunctionStatus value) {
    return value.to!string;
}
string[] toStrings(FunctionStatus[] values) {
    return values.map!(v => toString(v)).array;
}
///
unittest {
    mixin(ShowTest!"FunctionStatus");

    assert("building".toFunctionStatus == FunctionStatus.building);
    assert("deploying".toFunctionStatus == FunctionStatus.deploying);
    assert("running".toFunctionStatus == FunctionStatus.running);
    assert("error".toFunctionStatus == FunctionStatus.error);
    assert("inactive".toFunctionStatus == FunctionStatus.inactive);

    assert("".toFunctionStatus == FunctionStatus.error); // Default value for unknown strings is "error"
    assert("unknown".toFunctionStatus == FunctionStatus.error); // Default value for unknown strings is "error"

    assert(toString(FunctionStatus.building) == "building");
    assert(toString(FunctionStatus.deploying) == "deploying");
    assert(toString(FunctionStatus.running) == "running");
    assert(toString(FunctionStatus.error) == "error");
    assert(toString(FunctionStatus.inactive) == "inactive");

    assert(toFunctionStatus(["building", "running", "invalid"]) == [FunctionStatus.building, FunctionStatus.running, FunctionStatus.error]);
    assert(toString([FunctionStatus.building, FunctionStatus.inactive]) == ["building", "inactive"]);
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
ScalingType[] toScalingType(string[] values) {
    return values.map!(v => toScalingType(v)).array;
}
string toString(ScalingType value) {
    return value.to!string;
}
string[] toStrings(ScalingType[] values) {
    return values.map!(v => toString(v)).array;
}
///
unittest {
    mixin(ShowTest!"ScalingType");

    assert("auto".toScalingType == ScalingType.auto_);
    assert("fixed".toScalingType == ScalingType.fixed);

    assert("".toScalingType == ScalingType.auto_); // Default value for unknown strings is "auto"
    assert("unknown".toScalingType == ScalingType.auto_); // Default value for unknown strings is "auto"

    assert(toString(ScalingType.auto_) == "auto");
    assert(toString(ScalingType.fixed) == "fixed");

    assert(toScalingType(["auto", "fixed", "invalid"]) == [ScalingType.auto_, ScalingType.fixed, ScalingType.auto_]);
    assert(toString([ScalingType.auto_, ScalingType.fixed]) == ["auto", "fixed"]);
}

/// API rule access strategy.
enum AccessStrategy {
    noAuth,
    oauth2Introspection,
    jwt,
    allowAll,
}
AccessStrategy toAccessStrategy(string value) {
    mixin(EnumSwitch!"AccessStrategy", "noAuth");
}
AccessStrategy[] toAccessStrategy(string[] values) {
    return values.map!(v => toAccessStrategy(v)).array;
}
string toString(AccessStrategy value) {
    return value.to!string;
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
