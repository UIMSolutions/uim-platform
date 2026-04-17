module uim.platform.kyma.domain.enumerations;

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
    nodejs18,
    nodejs20,
    python39,
    python312,
}

  private FunctionRuntime toRuntime(string runtimeName) {
    switch (runtimeName) {
    case "nodejs18":
      return FunctionRuntime.nodejs18;
    case "nodejs20":
      return FunctionRuntime.nodejs20;
    case "python39":
      return FunctionRuntime.python39;
    case "python312":
      return FunctionRuntime.python312;
    default:
      return FunctionRuntime.nodejs20;
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
enum ApiHttpMethod {
    get_,
    post_,
    put_,
    patch_,
    delete_,
    head_,
    options_,
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
enum ModuleType {
    istio,
    apiGateway,
    serverless,
    eventing,
    nats,
    telemetry,
    btp_operator,
    keda,
    connectivityProxy,
    custom,
}

ModuleType toModuleType(string typeName) {
    switch (typeName) {
    case "istio":
        return ModuleType.istio;
    case "api-gateway":
        return ModuleType.apiGateway;
    case "serverless":
        return ModuleType.serverless;
    case "eventing":
        return ModuleType.eventing;
    case "nats":
        return ModuleType.nats;
    case "telemetry":
        return ModuleType.telemetry;
    case "btp-operator":
        return ModuleType.btp_operator;
    case "keda":
        return ModuleType.keda;
    case "connectivity-proxy":
        return ModuleType.connectivityProxy;
    default:
        return ModuleType.custom;
    }
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
