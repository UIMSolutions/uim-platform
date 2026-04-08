/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct KymaEnvironmentId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct NamespaceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct FunctionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ApiRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceInstanceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceBindingId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct EventSubscriptionId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ModuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ApplicationId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

// struct TenantId {
//   string value;

//   this(string value) {
//     this.value = value;
//   }

//   mixin DomainId;
// }

struct SubaccountId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ClusterId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

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
