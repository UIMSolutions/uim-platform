/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the Kyma aggregates.
/// (SubaccountId, ServiceInstanceId, ServiceBindingId and ApplicationId come
/// from uim-framework.)
module uim.platform.kyma.domain.types.ids;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A Kyma runtime (managed Kubernetes cluster).
struct KymaEnvironmentId {
  mixin(IdTemplate);
}

/// The Gardener shoot cluster behind an environment.
struct ClusterId {
  mixin(IdTemplate);
}

/// A Kubernetes namespace inside an environment.
struct NamespaceId {
  mixin(IdTemplate);
}

/// A serverless function (Function CR).
struct ServerlessFunctionId {
  mixin(IdTemplate);
}

/// An API rule (APIRule CR).
struct ApiRuleId {
  mixin(IdTemplate);
}

/// An eventing subscription (Subscription CR).
struct EventSubscriptionId {
  mixin(IdTemplate);
}

/// A Kyma module in an environment.
struct KymaModuleId {
  mixin(IdTemplate);
}
