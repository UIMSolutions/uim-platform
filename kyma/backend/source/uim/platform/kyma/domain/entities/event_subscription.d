/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.event_subscription;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// An eventing subscription (eventing.kyma-project.io Subscription): delivers
/// CloudEvents of the given types from a source to a sink.
struct EventSubscription {
  mixin TenantEntity!EventSubscriptionId;

  KymaEnvironmentId environmentId;
  NamespaceId namespaceId;
  string namespaceName;
  string name;
  string description;
  SubscriptionStatus status = SubscriptionStatus.pending;

  // Source
  string source;
  string[] eventTypes;
  EventTypeEncoding typeEncoding = EventTypeEncoding.exact;

  // Sink
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort = 80;

  int maxInFlightMessages = 10;
  KeyValue[] filterAttributes;
  KeyValue[] labels;
}
