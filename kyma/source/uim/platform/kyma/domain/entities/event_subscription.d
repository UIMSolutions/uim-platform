/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.event_subscription;

// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// An event subscription — subscribes to events from a source.
struct EventSubscription {
  TenantId tenantId;
  EventSubscriptionId id;
  NamespaceId namespaceId;
  KymaEnvironmentId environmentId;
  string name;
  string description;
  SubscriptionStatus status = SubscriptionStatus.pending;

  // Event source
  string source;
  string[] eventTypes;
  EventTypeEncoding typeEncoding = EventTypeEncoding.exact;

  // Sink — the target to deliver events to
  string sinkUrl;
  string sinkServiceName;
  int sinkServicePort;

  // Configuration
  int maxInFlightMessages = 10;
  bool exactTypeMatching = true;

  // Filters
  string[string] filterAttributes;

  // Labels
  string[string] labels;

  // Metadata
  string createdBy;
  long createdAt;
  long modifiedAt;
}
