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
    return values.map!toEnvironmentStatus.array;
}
string toString(EnvironmentStatus value) {
    return value.to!string;
}
string[] toStrings(EnvironmentStatus[] values) {
    return values.map!toString.array;
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

    assert(toStrings([EnvironmentStatus.provisioning, EnvironmentStatus.running, EnvironmentStatus.updating, EnvironmentStatus.stopping, EnvironmentStatus.stopped, EnvironmentStatus.deprovisioning, EnvironmentStatus.error]) == ["provisioning", "running", "updating", "stopping", "stopped", "deprovisioning", "error"]);
    assert(toEnvironmentStatuses(["provisioning", "running", "updating", "stopping", "stopped", "deprovisioning", "error"]) == [EnvironmentStatus.provisioning, EnvironmentStatus.running, EnvironmentStatus.updating, EnvironmentStatus.stopping, EnvironmentStatus.stopped, EnvironmentStatus.deprovisioning, EnvironmentStatus.error]);
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
KymaPlan[] toKymaPlans(string[] values) {
    return values.map!toKymaPlan.array;
}
string toString(KymaPlan value) {
    return value.to!string;
}
string[] toStrings(KymaPlan[] values) {
    return values.map!toString.array;
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

    assert(toStrings([KymaPlan.azure, KymaPlan.aws, KymaPlan.gcp, KymaPlan.sapConvergedCloud, KymaPlan.free_, KymaPlan.trial]) == ["azure", "aws", "gcp", "sapConvergedCloud", "free", "trial"]);
    assert(toKymaPlans(["azure", "aws", "gcp", "sapConvergedCloud", "free", "trial"]) == [KymaPlan.azure, KymaPlan.aws, KymaPlan.gcp, KymaPlan.sapConvergedCloud, KymaPlan.free_, KymaPlan.trial]);
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
    return values.map!toNamespaceStatus.array;
}
string toString(NamespaceStatus value) {
    return value.to!string;
}
string[] toStrings(NamespaceStatus[] values) {   
    return values.map!toString.array;
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

    assert(toStrings([NamespaceStatus.active, NamespaceStatus.terminating]) == ["active", "terminating"]);
    assert(toNamespaceStatuses(["active", "terminating"]) == [NamespaceStatus.active, NamespaceStatus.terminating]);
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
FunctionRuntime[] toFunctionRuntimes(string[] values) {
    return values.map!toFunctionRuntime.array;
}
string toString(FunctionRuntime value) {
    return value.to!string;
}
string[] toStringArray(FunctionRuntime[] values) {
    return values.map!toString.array;
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

    assert(toFunctionRuntimes(["nodejs20", "python39", "invalid"]) == [FunctionRuntime.nodejs20, FunctionRuntime.python39, FunctionRuntime.nodejs20]);
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
    return values.map!toFunctionStatus.array;
}
string toString(FunctionStatus value) {
    return value.to!string;
}
string[] toStrings(FunctionStatus[] values) {
    return values.map!toString.array;
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

    assert(toFunctionStatuses(["building", "running", "invalid"]) == [FunctionStatus.building, FunctionStatus.running, FunctionStatus.error]);
    assert(toStrings([FunctionStatus.building, FunctionStatus.inactive]) == ["building", "inactive"]);
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
ScalingType[] toScalingTypes(string[] values) {
    return values.map!toScalingType.array;
}
string toString(ScalingType value) {
    return value.to!string;
}
string[] toStrings(ScalingType[] values) {
    return values.map!toString.array;
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

    assert(toScalingTypes(["auto", "fixed", "invalid"]) == [ScalingType.auto_, ScalingType.fixed, ScalingType.auto_]);
    assert(toStrings([ScalingType.auto_, ScalingType.fixed]) == ["auto", "fixed"]);
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
AccessStrategy[] toAccessStrategies(string[] values) {
    return values.map!toAccessStrategy.array;
}
string toString(AccessStrategy value) {
    return value.to!string;
}
/// 
unittest {
    mixin(ShowTest!"AccessStrategy");

    assert("noauth".toAccessStrategy == AccessStrategy.noAuth);
    assert("oauth2introspection".toAccessStrategy == AccessStrategy.oauth2Introspection);
    assert("jwt".toAccessStrategy == AccessStrategy.jwt);
    assert("allowall".toAccessStrategy == AccessStrategy.allowAll);

    assert("".toAccessStrategy == AccessStrategy.noAuth); // Default value for unknown strings is "noAuth"
    assert("unknown".toAccessStrategy == AccessStrategy.noAuth); // Default value for unknown strings is "noAuth"

    assert(toString(AccessStrategy.noAuth) == "noAuth");
    assert(toString(AccessStrategy.oauth2Introspection) == "oauth2Introspection");
    assert(toString(AccessStrategy.jwt) == "jwt");
    assert(toString(AccessStrategy.allowAll) == "allowAll");

    assert(toAccessStrategies(["noauth", "jwt", "invalid"]) == [AccessStrategy.noAuth, AccessStrategy.jwt, AccessStrategy.noAuth]);
    assert([AccessStrategy.noAuth, AccessStrategy.jwt, AccessStrategy.noAuth].toStrings == ["noAuth", "jwt", "noAuth"]);
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

ApiRuleStatus[] toApiRuleStatuses(string[] values) {
    return values.map!toApiRuleStatus.array;
}

string toString(ApiRuleStatus value) {
    return value.to!string;
}

string[] toStrings(ApiRuleStatus[] values) {
    return values.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!"ApiRuleStatus");

    assert("ok".toApiRuleStatus == ApiRuleStatus.ok);
    assert("error".toApiRuleStatus == ApiRuleStatus.error);
    assert("notready".toApiRuleStatus == ApiRuleStatus.notReady);

    assert("".toApiRuleStatus == ApiRuleStatus.error); // Default value for unknown strings is "error"
    assert("unknown".toApiRuleStatus == ApiRuleStatus.error); // Default value for unknown strings is "error"

    assert(toString(ApiRuleStatus.ok) == "ok");
    assert(toString(ApiRuleStatus.error) == "error");
    assert(toString(ApiRuleStatus.notReady) == "notReady");

    assert(toApiRuleStatuses(["ok", "notready", "invalid"]) == [ApiRuleStatus.ok, ApiRuleStatus.notReady, ApiRuleStatus.error]);
    assert([ApiRuleStatus.ok, ApiRuleStatus.notReady, ApiRuleStatus.error].toStrings == ["ok", "notReady", "error"]);
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

ApiHttpMethod[] toApiHttpMethods(string[] values) {
    return values.map!toApiHttpMethod.array;
}

string toString(ApiHttpMethod value) {
    return value.to!string;
}

string[] toStrings(ApiHttpMethod[] values) {
    return values.map!toString.array;
}

/// 
unittest {
    mixin(ShowTest!"ApiHttpMethod");

    assert("GET".toApiHttpMethod == ApiHttpMethod.get_);
    assert("POST".toApiHttpMethod == ApiHttpMethod.post_);
    assert("PUT".toApiHttpMethod == ApiHttpMethod.put_);
    assert("PATCH".toApiHttpMethod == ApiHttpMethod.patch_);
    assert("DELETE".toApiHttpMethod == ApiHttpMethod.delete_);
    assert("HEAD".toApiHttpMethod == ApiHttpMethod.head_);
    assert("OPTIONS".toApiHttpMethod == ApiHttpMethod.options_);

    assert("".toApiHttpMethod == ApiHttpMethod.get_); // Default value for unknown strings is "GET"
    assert("unknown".toApiHttpMethod == ApiHttpMethod.get_); // Default value for unknown strings is "GET"

    assert(toString(ApiHttpMethod.get_) == "GET");
    assert(toString(ApiHttpMethod.post_) == "POST");
    assert(toString(ApiHttpMethod.put_) == "PUT");
    assert(toString(ApiHttpMethod.patch_) == "PATCH");
    assert(toString(ApiHttpMethod.delete_) == "DELETE");
    assert(toString(ApiHttpMethod.head_) == "HEAD");
    assert(toString(ApiHttpMethod.options_) == "OPTIONS");

    assert(toApiHttpMethods(["GET", "POST", "INVALID"]) == [ApiHttpMethod.get_, ApiHttpMethod.post_, ApiHttpMethod.get_]);
    assert([ApiHttpMethod.get_, ApiHttpMethod.post_, ApiHttpMethod.get_].toStrings == ["GET", "POST", "GET"]);
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
    mixin(EnumSwitch!"ServiceInstanceStatus", "failed");
}

ServiceInstanceStatus[] toServiceInstanceStatuses(string[] values) {
    return values.map!toServiceInstanceStatus.array;
}

string toString(ServiceInstanceStatus value) {
    return value.to!string;
}

string[] toStrings(ServiceInstanceStatus[] values) {
    return values.map!toString.array;
}

///
unittest {
    mixin(ShowTest!"ServiceInstanceStatus");

    assert("creating".toServiceInstanceStatus == ServiceInstanceStatus.creating);
    assert("ready".toServiceInstanceStatus == ServiceInstanceStatus.ready);
    assert("failed".toServiceInstanceStatus == ServiceInstanceStatus.failed);
    assert("deleting".toServiceInstanceStatus == ServiceInstanceStatus.deleting);
    assert("updating".toServiceInstanceStatus == ServiceInstanceStatus.updating);

    assert("".toServiceInstanceStatus == ServiceInstanceStatus.failed); // Default value for unknown strings is "failed"
    assert("unknown".toServiceInstanceStatus == ServiceInstanceStatus.failed); // Default value for unknown strings is "failed"

    assert(toString(ServiceInstanceStatus.creating) == "creating");
    assert(toString(ServiceInstanceStatus.ready) == "ready");
    assert(toString(ServiceInstanceStatus.failed) == "failed");
    assert(toString(ServiceInstanceStatus.deleting) == "deleting");
    assert(toString(ServiceInstanceStatus.updating) == "updating");

    assert(toServiceInstanceStatuses(["creating", "ready", "invalid"]) == [ServiceInstanceStatus.creating, ServiceInstanceStatus.ready, ServiceInstanceStatus.failed]);
    assert([ServiceInstanceStatus.creating, ServiceInstanceStatus.ready, ServiceInstanceStatus.failed].toStrings == ["creating", "ready", "failed"]);
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
    mixin(EnumSwitch!"ServiceBindingStatus", "failed");
}

ServiceBindingStatus[] toServiceBindingStatuses(string[] values) {
    return values.map!toServiceBindingStatus.array;
}

string toString(ServiceBindingStatus value) {
    return value.to!string;
}

string[] toStrings(ServiceBindingStatus[] values) {
    return values.map!toString.array;
}

///
unittest {
    mixin(ShowTest!"ServiceBindingStatus");

    assert("creating".toServiceBindingStatus == ServiceBindingStatus.creating);
    assert("ready".toServiceBindingStatus == ServiceBindingStatus.ready);
    assert("failed".toServiceBindingStatus == ServiceBindingStatus.failed);
    assert("deleting".toServiceBindingStatus == ServiceBindingStatus.deleting);

    assert("".toServiceBindingStatus == ServiceBindingStatus.failed); // Default value for unknown strings is "failed"
    assert("unknown".toServiceBindingStatus == ServiceBindingStatus.failed); // Default value for unknown strings is "failed"

    assert(toString(ServiceBindingStatus.creating) == "creating");
    assert(toString(ServiceBindingStatus.ready) == "ready");
    assert(toString(ServiceBindingStatus.failed) == "failed");
    assert(toString(ServiceBindingStatus.deleting) == "deleting");

    assert(toServiceBindingStatuses(["creating", "ready", "invalid"]) == [ServiceBindingStatus.creating, ServiceBindingStatus.ready, ServiceBindingStatus.failed]);
    assert([ServiceBindingStatus.creating, ServiceBindingStatus.ready, ServiceBindingStatus.failed].toStrings == ["creating", "ready", "failed"]);  
}

/// Event type encoding.
enum EventTypeEncoding {
    exact,
    prefix,
}

EventTypeEncoding toEventTypeEncoding(string value) {
    mixin(EnumSwitch!"EventTypeEncoding", "exact");
}

EventTypeEncoding[] toEventTypeEncodings(string[] values) {
    return values.map!toEventTypeEncoding.array;
}

string toString(EventTypeEncoding value) {
    return value.to!string;
}

string[] toStrings(EventTypeEncoding[] values) {
    return values.map!toString.array;
}

///
unittest {
    mixin(ShowTest!"EventTypeEncoding");

    assert("exact".toEventTypeEncoding == EventTypeEncoding.exact);
    assert("prefix".toEventTypeEncoding == EventTypeEncoding.prefix);

    assert("".toEventTypeEncoding == EventTypeEncoding.exact); // Default value for unknown strings is "exact"
    assert("unknown".toEventTypeEncoding == EventTypeEncoding.exact); // Default value for unknown strings is "exact"

    assert(EventTypeEncoding.exact.toString == "exact");
    assert(EventTypeEncoding.prefix.toString == "prefix");

    assert(toEventTypeEncodings(["exact", "prefix", "invalid"]) == [EventTypeEncoding.exact, EventTypeEncoding.prefix, EventTypeEncoding.exact]);
    assert([EventTypeEncoding.exact, EventTypeEncoding.prefix].toStrings == ["exact", "prefix"]);
}

/// Status of an event subscription.
enum SubscriptionStatus {
    active,
    pending,
    error,
    paused,
}

SubscriptionStatus toSubscriptionStatus(string s) {
    mixin(EnumSwitch!"SubscriptionStatus", "error");
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
